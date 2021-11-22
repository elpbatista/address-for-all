SET session statement_timeout to 600000;
-- 
SHOW statement_timeout;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Indexing
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DROP INDEX jplanet_osm_polygon_way_idx;
DROP INDEX teste_pts_medellin_geom_idx;
DROP INDEX test_feature_asis_vias_geom_idx;
--
CREATE INDEX jplanet_osm_polygon_way_idx ON jplanet_osm_polygon USING GIST (way);
CREATE INDEX teste_pts_medellin_geom_idx ON teste_pts_medellin USING SPGIST (geom);
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
-- Indexing for the Search
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP INDEX search_geom_idx;
CREATE INDEX search_geom_idx ON api.search USING SPGIST (geom);
CREATE INDEX search_properties_idx ON api.search USING GIN (properties jsonb_ops);
CREATE INDEX search_properties_address_idx ON api.search USING GIN ((properties->'address'));
CREATE INDEX search_properties_id_idx ON api.search USING GIN ((properties->'_id'));
CREATE INDEX search_q_trgm_idx ON api.search USING GIN (q gin_trgm_ops);
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
      b.geom::geography <->ST_POINT(-75.486799, 6.194510) as dist
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
          b.geom::geography <->ST_POINT(-75.486799, 6.194510) as dist
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
-- Address Look Up (it accepts either address or _id)
-- Potential conflict: address is not unique among the whole dataset 
-- It should be considered to return a  FeatureCollection instead a single Feature
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT json_agg(ST_AsGeoJSON(r, 'geom', 6)::json)
FROM (
    SELECT *
    FROM api.search s
    WHERE s.properties->>' address ' = ' CL 1BB #48A ESTE-522 (0130)'
      OR s.properties->>'_id' = '443091'
  ) r;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Respnse Formating V1.0
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT CASE
    j.features_count
    WHEN 1 THEN j.features
    ELSE json_build_object(
      'type',
      'FeatureCollection',
      'features',
      j.features
    )
  END AS response
FROM (
    SELECT count(r) AS features_count,
      json_agg(ST_AsGeoJSON(r, 'geom', 6)::json) AS features
    FROM (
        SELECT s.geom,
          s.properties->>'_id' AS _id,
          s.properties->>'address' AS address,
          s.properties->>'display_name' AS display_name,
          s.properties->>'barrio' AS barrio,
          s.properties->>'comuna' AS comuna,
          s.properties->>'municipality' AS municipality,
          s.properties->>'divipola' AS divipola,
          s.properties->>'country' AS country
        FROM api.search s
        LIMIT 3
      ) r
  ) j;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Full Text Search Bounded
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
WITH q AS (
  SELECT *,
    similarity('CL 107 42 Popular', bbox.q) AS sim
  FROM (
      SELECT *
      FROM api.search
      WHERE ST_Contains(
          ST_SetSRID(
            api.viewbox_to_polygon(-75.552, 6.291, -75.543, 6.297),
            4326
          ),
          geom
        )
    ) bbox
  ORDER BY sim DESC
  LIMIT 100
)
SELECT CASE
    j.features_count
    WHEN 1 THEN j.features
    ELSE json_build_object(
      'type',
      'FeatureCollection',
      'features',
      j.features
    )
  END AS response
FROM (
    SELECT count(r) AS features_count,
      json_agg(ST_AsGeoJSON(r, 'geom', 6)::json) AS features
    FROM (
        SELECT s.geom,
          s.properties->>'_id' AS _id,
          s.properties->>'address' AS address,
          s.properties->>'display_name' AS display_name,
          s.properties->>'barrio' AS barrio,
          s.properties->>'comuna' AS comuna,
          s.properties->>'municipality' AS municipality,
          s.properties->>'divipola' AS divipola,
          s.properties->>'country' AS country
        FROM (
            SELECT *
            FROM q
            WHERE q.sim > 0
          ) s
      ) r
  ) j;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Full Text Search Near a Point
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
WITH q AS (
  SELECT *,
    similarity('CL 107 42 Popular', nearby.q) AS sim
  FROM (
      SELECT *,
        b.geom::geography <->ST_POINT(-75.486799, 6.194510) as dist
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
    ) nearby
  ORDER BY sim DESC
  LIMIT 100
)
SELECT CASE
    j.features_count
    WHEN 1 THEN j.features
    ELSE json_build_object(
      'type',
      'FeatureCollection',
      'features',
      j.features
    )
  END AS response
FROM (
    SELECT count(r) AS features_count,
      json_agg(ST_AsGeoJSON(r, 'geom', 6)::json) AS features
    FROM (
        SELECT s.geom,
          s.properties->>'_id' AS _id,
          s.properties->>'address' AS address,
          s.properties->>'display_name' AS display_name,
          s.properties->>'barrio' AS barrio,
          s.properties->>'comuna' AS comuna,
          s.properties->>'municipality' AS municipality,
          s.properties->>'divipola' AS divipola,
          s.properties->>'country' AS country
        FROM (
            SELECT *
            FROM q
            WHERE q.sim > 0
          ) s
      ) r
  ) j;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  Testing pb's Functions
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
SELECT api.get_address(-75.486799, 6.194510);
SELECT api.get_addresses_near(-75.486799, 6.194510, 500);
SELECT api.get_addresses_in_bbox(-75.552, 6.291, -75.543, 6.297);
SELECT api.viewbox_to_polygon(-75.552, 6.291, -75.543, 6.297);
SELECT api.lookup('CL 1BB #48A ESTE-522 (0130)');
SELECT api.lookup('443091');
SELECT api.search('CL 107 42 Popular', 10);
SELECT api.search_bounded('CL 107 42 Popular', ARRAY [-75.552, 6.291, -75.543, 6.297], 10);
SELECT api.search_nearby('CL 107 42 Popular', ARRAY [-75.486799, 6.194510], 200, 10);