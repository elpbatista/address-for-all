SET session statement_timeout to 600000;
-- 
SHOW statement_timeout;
-- 
-- Indexing
-- 
DROP INDEX jplanet_osm_polygon_way_idx;
-- 
DROP INDEX teste_pts_medellin_geom_idx;
-- 
DROP INDEX test_feature_asis_vias_geom_idx;
--
CREATE INDEX jplanet_osm_polygon_way_idx ON jplanet_osm_polygon USING GIST (way);
-- 
CREATE INDEX teste_pts_medellin_geom_idx ON teste_pts_medellin USING SPGIST (geom);
-- 
CREATE INDEX test_feature_asis_vias_geom_idx ON test_feature_asis_vias USING GIST (geom);
-- 
CREATE SCHEMA api;
-- 
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA api;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE MATERIALIZED VIEW api.search AS -- 
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT r._id AS _id,
	r.geom AS geom,
	CONCAT(
		r.address,
		' ',
		r.display_name,
		' ',
		r.barrio,
		' ',
		r.comuna,
		' ',
		r.city,
		' ',
		r.municipality,
		' ',
		r.divipola,
		' ',
		r.cruce
	)::text AS q,
	jsonb_strip_nulls(
		to_jsonb(r) #-'{geom}') AS properties
		FROM (
				SELECT pts.feature_id AS _id,
					pts.geom AS geom,
					CONCAT(
						pts.properties->>'via',
						' #',
						pts.properties->>'house_number'
					) AS address,
					CONCAT (
						pts.properties->>'tipo_cruce',
						' ',
						SUBSTRING(pts.properties->>'house_number', '^[^-]+')
					) AS cruce,
					CONCAT(
						CASE
							pts.properties->>'tipo_via'
							WHEN 'AU' THEN 'Autopista'
							WHEN 'AV' THEN 'Avenida'
							WHEN 'BV' THEN 'Bulevar'
							WHEN 'CL' THEN 'Calle'
							WHEN 'KR' THEN 'Carrera'
							WHEN 'CT' THEN 'Carretera'
							WHEN 'CR' THEN 'Circunvalar'
							WHEN 'DG' THEN 'Diagonal'
							WHEN 'GL' THEN 'Glorieta'
							WHEN 'KM' THEN 'Kilómetro'
							WHEN 'TV' THEN 'Transversal'
							WHEN 'VT' THEN 'Variante'
							WHEN 'V' THEN 'Vía'
							ELSE 'Unknown'
						END,
						' ',
						CASE
							WHEN nvias.via_name IS NOT null THEN nvias.via_name
							ELSE SUBSTRING(pts.properties->>'via', '^\S+\s+(.+)$')
						END,
						' #',
						pts.properties->>'house_number'
					) AS display_name,
					nvias.via_name AS nombre,
					nvias.nombre_com AS nombrecom,
					administrative.tags->>'divipola' AS divipola,
					pts.properties->>'nombre_bar' AS barrio,
					pts.properties->>'nombre_com' AS comuna,
					SUBSTRING(administrative.tags->>'name', '^[^,]+') AS city,
					administrative.tags->>'is_in:state' AS municipality,
					administrative.tags->>'is_in:country' AS country
				FROM teste_pts_medellin pts
					LEFT JOIN administrative ON ST_Contains(administrative.way, pts.geom)
					CROSS JOIN LATERAL (
						SELECT vias.properties->>'label' AS via_label,
							CASE
								WHEN vias.properties->>'via_name' = pts.properties->>'via' THEN null
								WHEN pts.properties->>'via' != vias.properties->>'label' THEN null
								ELSE vias.properties->>'via_name'
							END AS via_name,
							CASE
								WHEN vias.properties->>'via_name' = vias.properties->>'nombre_com' THEN null
								ELSE vias.properties->>'nombre_com'
							END AS nombre_com,
							vias.geom <->pts.geom AS dist
						FROM test_feature_asis_vias vias
						ORDER BY dist
						LIMIT 1
					) nvias
			) r;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Successfully run. Total query runtime: 1 min 47 secs.
-- 474520 rows affected.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 
-- DROP INDEX search_geom_idx;
CREATE INDEX search_geom_idx ON api.search USING SPGIST (geom);
CREATE INDEX search_properties_idx ON api.search USING GIN (properties jsonb_ops);
CREATE INDEX search_q_trgm_idx ON api.search USING GIN (q gin_trgm_ops);
-- 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  Returns a single Feature
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT json_build_object(
		'type',
		'Feature',
		'geometry',
		geom,
		'properties',
		properties
	) AS result
FROM (
		SELECT *,
			b.geom::geography <-> ST_POINT(-75.486799, 6.194510) as dist
		FROM (
			SELECT *
			FROM api.search s
		WHERE ST_DWithin(
				s.geom::geography,
				ST_POINT(-75.486799, 6.194510),
				5
			)
		) b
		LIMIT 1
	) r;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Returns a FeatureCollection
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT json_build_object(
		'type',
		'FeatureCollection',
		'features',
		json_agg(ST_AsGeoJSON(r, 'geom', 6)::json)
	) AS result
FROM (
		SELECT geom,
			properties->>'_id' AS _id,
			properties->>'address' AS address,
			properties->>'display_name' AS display_name,
			properties->>'barrio' AS barrio,
			properties->>'comuna' AS comuna,
			properties->>'municipality' AS municipality,
			properties->>'divipola' AS divipola,
			properties->>'country' AS country
		FROM (
		SELECT *,
			b.geom::geography <-> ST_POINT(-75.486799, 6.194510) as dist
		FROM (
			SELECT *
			FROM api.search s
		WHERE ST_DWithin(
				s.geom::geography,
				ST_POINT(-75.486799, 6.194510),
				150
			)
		) b
		ORDER BY dist ASC
	) r;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Full Text
SELECT SHOW_TRGM('calle cordoba 52') AS cl52;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT similarity('calle 99 52 castilla', q) AS sim,
	q
FROM api.search
ORDER BY sim DESC
LIMIT 10;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  ViewBox to POLYGON
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT ST_AsText(
		ST_Envelope(
			ST_Collect(
				ST_Point(-75.552, 6.291),
				ST_Point(-75.543, 6.297)
			)
		)
	) As wktenv;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Full Text Search into a ViewBox
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT similarity('CL 107 42 Popular', r.q) AS sim,
	r.properties->>'address' AS address,
	CONCAT(
		r.properties->>'display_name',
		' ',
		r.properties->>'barrio',
		' ',
		r.properties->>'comuna',
		' ',
		r.properties->>'divipola',
		' ',
		r.properties->>'city'
	) AS label
FROM (
		SELECT *
		FROM api.search s
		WHERE ST_Contains(
				ST_SetSRID(
					api.viewbox_to_polygon(-75.552,6.291,-75.543,6.297),
					4326
				),
				s.geom
			)
	) r
-- WHERE similarity('CL 107 42 Popular', b.q) > 0
ORDER BY sim DESC
LIMIT 100;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  Full Text Search into a given radious V1
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT similarity('CL 107 42 Popular', r.q) AS sim,
	r.dist AS dist,
	r.properties->>'address' AS address,
	CONCAT(
		r.properties->>'display_name',
		' ',
		r.properties->>'barrio',
		' ',
		r.properties->>'comuna',
		' ',
		r.properties->>'divipola',
		' ',
		r.properties->>'city'
	) AS label
FROM (
		SELECT *,
			b.geom::geography <-> ST_POINT(-75.486799, 6.194510) as dist
		FROM (
			SELECT *
			FROM api.search s
		WHERE ST_DWithin(
				s.geom::geography,
				ST_POINT(-75.486799, 6.194510),
				200
			)
		) b
		ORDER BY dist ASC
	) r
ORDER BY sim DESC;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  Testing pb's Functions
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT api.get_address(-75.486799, 6.194510);
SELECT api.viewbox_to_polygon(-75.552,6.291,-75.543,6.297);
