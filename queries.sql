SELECT jsonb_pretty(tags)
FROM jplanet_osm_polygon
WHERE tags->>'name' = 'Medellín';
-- 
SELECT jsonb_pretty(properties)
FROM teste_pts_medellin
LIMIT 5;
-- ST_AsText(way)
-- ST_Area(way)ß
SELECT ST_AsGeoJSON(way)
FROM jplanet_osm_polygon
WHERE tags->>'name' = 'Medellín';
-- 
SELECT jsonb_pretty(tags)
FROM jplanet_osm_polygon
WHERE tags->>'boundary' = 'administrative';
-- 
SELECT jsonb_pretty(tags)
FROM jplanet_osm_roads
WHERE tags->>'highway' IS NOT NULL
	AND tags->>'name' IS NOT NULL
LIMIT 50;
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
-- Indexing
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
-- 
SELECT teste_pts_medellin.properties->>'via' AS via,
	test_feature_asis_vias.properties->>'via_name' AS nombre,
	test_feature_asis_vias.properties->>'nombre_com' AS nombre_com
FROM teste_pts_medellin,
	test_feature_asis_vias
WHERE ST_DWithin(
		test_feature_asis_vias.geom,
		teste_pts_medellin.geom,
		10
	)
	AND teste_pts_medellin.properties->>'via' LIKE test_feature_asis_vias.properties->>'label'
GROUP BY via,
	nombre,
	nombre_com;