-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Escenarios críticos que se pueden propiciar a partir de llamadas al API
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 
-- Caso de Uso #1
-- Bucar todas las direcciones de Colombia
-- Devuelve una FeatureCollection con 474520 features
SELECT api.search('Colombia', null);
-- 
-- Caso de Uso #2
-- Devuelve todas las direcciones en un radio de 100km
-- Devuelve una FeatureCollection con 474520 features
SELECT api.search_nearby(
        'calle',
        ARRAY [-75.486799, 6.194510],
        100000,
        null
    );
-- 	
-- Caso de Uso #3
-- Recuperar todas las direcciones como GeoJSON (features)
-- Devuelve 474520 filas
SELECT api.lookup(properties->>'address') AS features
FROM api.search;