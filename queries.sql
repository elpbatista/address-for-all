SELECT DISTINCT
    SUBSTRING(properties->>'label', '^[^#]+') AS via,
    properties->>'nombre_com' AS common_name
FROM
    test_feature_asis_vias
WHERE 
    properties->>'label'<>properties->>'via_name' AND
    properties->>'nombre_com'<>'null'
LIMIT 40;

SELECT DISTINCT
    properties->>'via' AS via,
    properties->>'nombre_com' AS common_name,
    properties->>'house_number' AS placa,
    properties->>'nombre_bar' AS barrio
FROM
    teste_pts_medellin
WHERE 
    properties->>'nombre_com'='BUENOS AIRES' 
LIMIT 40;