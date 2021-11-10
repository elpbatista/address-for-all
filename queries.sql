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
-- 
-- ST_AsGeoJSON(way)
-- ST_Area(way)ß
SELECT ST_AsText(way)
FROM jplanet_osm_polygon
WHERE tags->>'name' = 'Medellín';
-- 
SELECT tags
FROM jplanet_osm_polygon
WHERE tags->>'boundary' = 'administrative';
-- 
-- Buscando nombre de calles en las ways de OSM
-- 
SELECT tags->>'name' AS display_name,
	tags->>'alt_name' AS alt_name,
	tags->>'nat_name' AS nat_name,
	tags->>'int_name' AS int_name
FROM jplanet_osm_roads
WHERE tags->>'highway' IS NOT NULL
	AND tags->>'name' IS NOT NULL
GROUP BY display_name,
	alt_name,
	nat_name,
	int_name;
-- 
-- Mejorar la regex queda un espacio al final
SELECT DISTINCT SUBSTRING(properties->>'label', '^[^#]+') AS via,
	properties->>'nombre_com' AS common_name,
	properties->>'label' AS addr
FROM test_feature_asis_vias
WHERE properties->>'label' <> properties->>'via_name'
	AND properties->>'nombre_com' <> 'null'
LIMIT 40;
-- 
SELECT DISTINCT properties->>'via' AS via,
	properties->>'nombre_com' AS common_name,
	properties->>'house_number' AS placa,
	properties->>'nombre_bar' AS barrio
FROM teste_pts_medellin
WHERE properties->>'nombre_com' = 'BUENOS AIRES'
LIMIT 40;
-- 
-- Medellín (SOM Planet)
-- 3061 vías
-- 2134 vías con nombre
--  183 nombres distintos
SELECT COUNT(jplanet_osm_roads.tags->>'name') AS amnt,
	jplanet_osm_roads.tags->>'name' AS via,
	jplanet_osm_roads.tags->>'alt_name' AS otro,
	jplanet_osm_roads.tags->>'nat_name' AS nacn
FROM jplanet_osm_roads
WHERE ST_Within(
		jplanet_osm_roads.way,
		(
			SELECT jplanet_osm_polygon.way
			FROM jplanet_osm_polygon
			WHERE tags->>'name' = 'Medellín'
		)
	)
	AND jplanet_osm_roads.tags->>'highway' IS NOT NULL
	AND jplanet_osm_roads.tags->>'name' IS NOT NULL
GROUP BY via,
	otro,
	nacn
ORDER BY amnt,
	via;
-- 
-- 
-- 
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
)
SELECT teste_pts_medellin.properties->>'via' AS via,
	teste_pts_medellin.properties->>'house_number' AS placa,
	administrative.tags->>'divipola' AS divipola,
	administrative.tags->>'name' AS city,
	administrative.tags->>'is_in:state' AS muni
FROM teste_pts_medellin,
	administrative
WHERE ST_Within(teste_pts_medellin.geom, administrative.way)
	AND administrative.tags->>'admin_level' = '6';
-- 
-- 
-- 
SELECT COUNT(jplanet_osm_roads.tags->>'name') AS amnt,
	jplanet_osm_roads.tags->>'name' AS via,
	jplanet_osm_roads.tags->>'alt_name' AS otro,
	jplanet_osm_roads.tags->>'nat_name' AS nacn
FROM jplanet_osm_roads
WHERE jplanet_osm_roads.tags->>'highway' IS NOT NULL
	AND jplanet_osm_roads.tags->>'name' IS NOT NULL
GROUP BY via,
	otro,
	nacn
ORDER BY amnt,
	via;
-- 
-- 
-- 
-- 
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT administrative.tags->>'divipola' AS divipola,
	SUBSTRING(administrative.tags->>'name', '^[^,]+') AS city,
	administrative.tags->>'is_in:state' AS muni,
	administrative.tags->>'is_in:country' AS country
FROM teste_pts_medellin
	JOIN administrative ON ST_Contains(administrative.way, teste_pts_medellin.geom)
GROUP BY divipola,
	city,
	muni,
	country;
-- 
-- ########################################################################
-- 
--
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT teste_pts_medellin.properties->>'via' AS via,
	teste_pts_medellin.properties->>'house_number' AS placa,
	administrative.tags->>'divipola' AS divipola,
	SUBSTRING(administrative.tags->>'name', '^[^,]+') AS city,
	administrative.tags->>'is_in:state' AS muni,
	administrative.tags->>'is_in:country' AS country
FROM teste_pts_medellin
	JOIN administrative ON ST_Contains(administrative.way, teste_pts_medellin.geom);
-- 
-- 
-- ************************************************************************
-- 
SELECT pts.properties->>'via' AS via,
	vias.via_label AS labl,
	pts.properties->>'house_number' AS addr_placa,
	vias.via_name AS nombre,
	vias.nombre_com AS nombrecom,
	vias.dist
FROM teste_pts_medellin pts
	CROSS JOIN LATERAL (
		SELECT vias.properties->>'label' AS via_label,
			vias.properties->>'via_name' AS via_name,
			vias.properties->>'nombre_com' AS nombre_com,
			vias.geom <->pts.geom AS dist
		FROM test_feature_asis_vias vias
		WHERE pts.properties->>'via' LIKE vias.properties->>'label'
		ORDER BY dist
		LIMIT 1
	) vias
LIMIT 3000;
-- 
-- 
-- ************************************************************************
-- 5 min 39 sec
-- ************************************************************************
-- 
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT pts.properties->>'via' AS via,
	pts.properties->>'house_number' AS placa,
	pts.properties->>'tipo_cruce' AS cruce,
	vias.via_name AS nombre,
	vias.nombre_com AS nombrecom,
	administrative.tags->>'divipola' AS divipola,
	pts.properties->>'nombre_bar' AS barrio,
	pts.properties->>'nombre_com' AS comunna,
	SUBSTRING(administrative.tags->>'name', '^[^,]+') AS city,
	administrative.tags->>'is_in:state' AS munipality,
	administrative.tags->>'is_in:country' AS country,
	vias.dist
FROM teste_pts_medellin pts
	LEFT JOIN administrative ON ST_Contains(administrative.way, pts.geom)
	CROSS JOIN LATERAL (
		SELECT vias.properties->>'label' AS via_label,
			vias.properties->>'via_name' AS via_name,
			vias.properties->>'nombre_com' AS nombre_com,
			vias.geom <->pts.geom AS dist
		FROM test_feature_asis_vias vias
		WHERE pts.properties->>'via' LIKE vias.properties->>'label'
		ORDER BY dist
		LIMIT 1
	) vias;
-- WHERE vias.nombre_com IS NOT NULL
-- LIMIT 3000;
-- ************************************************************************
-- 
-- ************************************************************************
WITH administrative AS (
	SELECT *
	FROM jplanet_osm_polygon
	WHERE tags->>'boundary' = 'administrative'
		AND tags->>'admin_level' = '6'
)
SELECT pts.feature_id AS _id,
	pts.geom AS geom,
	pts.properties->>'via' AS via,
	pts.properties->>'house_number' AS placa,
	pts.properties->>'tipo_cruce' AS cruce,
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
				WHEN vias.properties->>'via_name' = pts.properties->>'via' THEN ''
         		WHEN pts.properties->>'via' != vias.properties->>'label' THEN ''
         		ELSE vias.properties->>'via_name' END
         		AS via_name,
			CASE
				WHEN vias.properties->>'via_name' = vias.properties->>'nombre_com' THEN ''
         		ELSE vias.properties->>'nombre_com' END
         		AS nombre_com,
			vias.geom<->pts.geom AS dist
		FROM test_feature_asis_vias vias
		ORDER BY dist
		LIMIT 1
	) nvias
LIMIT 1000;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT 
  a.id, a.name, 
  ( 
    SELECT json_agg(item)
    FROM (
      SELECT b.c1 AS x, b.c2 AS y 
      FROM b WHERE b.item_id = a.id
    ) item
  ) AS items
FROM a;