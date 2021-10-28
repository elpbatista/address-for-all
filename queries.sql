SELECT jsonb_pretty(tags)
FROM jplanet_osm_polygon
WHERE tags->>'name' = 'Medellín';
-- 
-- ST_AsText(way)
-- ST_Area(way)ß
SELECT ST_AsGeoJSON(way)
FROM jplanet_osm_polygon
WHERE tags->>'name' = 'Medellín';
-- 
SELECT jsonb_pretty(tags)
FROM jplanet_osm_roads
WHERE tags->>'highway' IS NOT NULL
    AND tags->>'name' IS NOT NULL
LIMIT 50;
-- Mejorar la regex queda un espacio al final
SELECT DISTINCT SUBSTRING(properties->>'label', '^[^#]+') AS via,
    properties->>'nombre_com' AS common_name
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
-- 3061 vías con nombre
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
GROUP BY via, otro, nacn
ORDER BY amnt, via;