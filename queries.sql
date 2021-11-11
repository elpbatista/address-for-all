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
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Successfully run. Total query runtime: 1 min 41 secs.
-- 474520 rows affected.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT r._id AS _id,
	r.geom AS geom,
	jsonb_strip_nulls(
		to_jsonb(r) #-'{_id}'#-'{geom}') AS properties
		FROM (
				SELECT pts.feature_id AS _id,
					pts.geom AS geom,
					CONCAT(
						pts.properties->>'via',
						' #',
						pts.properties->>'house_number'
					) AS address,
					pts.properties->>'tipo_cruce' AS cruce,
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
					pts.properties->>'nombre_com' AS comunna,
					SUBSTRING(administrative.tags->>'name', '^[^,]+') AS city,
					administrative.tags->>'is_in:state' AS munipality,
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