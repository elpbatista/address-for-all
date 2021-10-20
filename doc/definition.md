# Definición

Este documetno es un borrador por lo que está sujeto a cambios, enmiendas, adiciones y correcciones hasta que todos quedemos conformes y se comparta la versión final a finales de esta semana, la cual vamos a usar como referencias para las posteriores etapas del proyecto.  
Aquí deberá quedar plasmado y descrito cada uno de los requerimientos, los que se retringirán al alcance del proyecto hasta donde ha sido concebido.

## URL

Esta URL es usada solo a los efectos de este documento. Debe ser sistituida por la dirección donde va a estar alejado el servicio.

`http(s)://api.address4all.org/`

## Endpoints

A continuación se definen los siguientes endpoints:

- /search ⟹ direcciones a partir de texto libre
- /reverse ⟹ direcciones a partir de su localización
- /lookup ⟹ direcciones a partir de su id (CID?)
- /doc, /help ⟹ devuelve este documento

Una propuesta para facilitar el uso por parte de los desarrolladores es si se invoca `URL+endpoint` sin parámetros, o sea nada a partir de `?` devuelver una especie de capability. Una docuemto donde se especifique qué contiene cada parámetro y qué se espera obtener como respuesta.

### Búsqueda de Direcciones o Geocodificación

      https://api.address4all.org/search?<params>

La consulta puede especificarse con los siguientes parámetros:

- `q=<query>` Cadena de texto libre para buscar
- `a=<address>` Dirección estandarizada según la Nomenclatura Predial Urbana

Búsqueda estructurada: Aãdir parámetros separados por coma `,`. Estos son algunos de los propuestos por Nominatim, habría que mirar los niveles administrativos y otras propiedades para adaptarlos a nuesto caso.

- `city=<city>`
- `county=<county>`
- `state=<state>`
- `country=<country>`
- `postalcode=<postalcode>`

Parámetros adicionales: Su objetvo es acotar el alcance de la búsqueda así como la cantidad de resultados.

- `limit=<integer>` Cantidad de resultados retornados.
- `viewbox|bbox=<lon1>,<lat1>,<lon2>,<lat2>`

### Recuperación de direcciones

La recuperación permite obetener una o varias direcciones a partir de su CID.

El API de búsqueda tiene el siguiente formato:

      https://api.address4all.org/lookup?cids=<value>,…,…,&<params>

### Geocodificación Inversa

      https://api.address4all.org/reverse?lat=<value>&lon=<value>&<params>

- `offset=<radius>` Default 3 (metros)

A nivel de servicio se podría resolver de la siguiente manera:

```sql
SELECT "address", ST_Distance(geom, ST_MakePoint(lon, lat)) AS distance
FROM "addresses"
WHERE  distance <= offset
ORDER BY distance
LIMIT 1;
```

Los etiquetas no son precisas, `"address"` y `"addresses"` no necesariramente se corresponden con la BD, esto es solo un ejemplo. También podrían probarse otros métodos en pos de encontrar el desempeño óptimo.

## Response

:fire: Tomado de Lupap Developers. Debe ser adaptado a A4A en función de los datos conque se cuenta.

- La API devuelve una colección de objetos geográficos `FeatureCollection` codificada en forma de GeoJSON. Cada dirección está representada por un punto o sea un objeto del tipo `Feature` con `Feature.geometry.type = "Point"` y un grupo de propiedades `properties` que todavía requieren cierto grado de refinamiento.
  - `features.length() = 0`: la búnqueda no arrojó ningún resultado
  - `features.length() > 0`: la búnsqueda ha sido exitosa.
    - `features.length() = 1`: el resultado es exacto.
    - `features.length() > 1`: se necesita desambigüación.
- Se añadió el código **DIVIPOLA** por recomendación de Freddy por ser de uso muy frecuente entre los locales, inlcuso por encima del Código Postal.
- Los niveles administrativos requieren una pasada de mano con mayor atención. No estoy seguro si se quiere guardar alguna compatibilidad con el resto de los sets de datos del proyecto ¿a quién lse lee puede preguntar?

```json
{
   "response" : {
      "type" : "FeatureCollection",
      "features" : [ // arreglo de objetos de tipo Feature
          {
              "type" : "Feature",
              "geometry" : {
                  "type" : "Point",
                  "coordinates": [
                      -74.04659813699993,
                      4.720145423000076
                  ]
              },
              "properties" : {
                 "accuracy": "rooftop",
                 "country": "co",
                 "city": "bogota",
                 "attribution": "geoapps",
                 "commonName": "AVENIDA SANTA BARBARA",
                 "address": "AK 19 # 135 - 30",
                 "postcode": "110121",
                 "divipolacode": "15001001",
                 "admin1": "Colombia",
                 "admin2": "Bogotá D.C.",
                 "admin3": "Bogotá D.C.",
                 "admin4": "Usaquen",
                 "admin5": "El Contador"
             }
          }

      ... // mas objetos de tipo Feature

      ]
   }
}
```

## Notas

### Nomenclatura Predial Urbana

```text
   vía          placa  complemento
├───────┼─┼─────────────┼───────┤
AV 6 BIS # 28 NORTE - 09 APT 201
          ├────────┼─┼──┤
             cruce    distancia aproximada en metros
```

- `vía` se correposnde con la vía principal.
- `cruce` también aparece como vía generadora.

### Estandarización de Direcciones

Direcciones urbanas asignadas según la malla vial.

| Dirección                      | Dirección estandarizada |
| ------------------------------ | ----------------------- |
| Carrera 20 #13 a 45            | KR 20 13 A 45           |
| Calle 9 No 34 – 30 Las Acacias | CL 9 34 30 LAS ACACIAS  |
| Cll 18 26 - 54 Centro          | CL 18 26 54 CENTRO      |
| Calle 3 15 62 Caicedo Alto     | CL 3 15 62 CAICEDO ALTO |

Direcciones urbanas asignadas según la nomenclatura `barrio - manzana - predio`.

| Dirección                        | Dirección estandarizada   |
| -------------------------------- | ------------------------- |
| Manzana 10 Casa 9 Mzna 2 Casa 1A | MZ 10 CS 9 MZ 2 CS 1A     |
| Mzna 10 F Csa 2 B/ Nueva Aranda  | MZ 10 CS 2 B NUEVA ARANDA |
| Barrio La Paz Mz K Cs 9          | BARRIO LA PAZ MZ K CS 9   |

### Direcciones Atípicas

Existen las direcciones atípicas, que no tienen la estructura descrita anteriormente. Los siguientes son ejemplos de direcciones atípicas:

- Vereda Guayabal Lote 6 Casa 2
- Km 5 Via La Calera Lote 101
- Urbanización Villa Irina Manzana F Lote 9
- Urbanización Villa de la Victoria Casa 12

## Referencias

1. <https://developer.lupap.com>
2. <https://geojson.org>
3. <https://nominatim.org/release-docs/develop/>
4. <https://en.wikipedia.org/wiki/Box-drawing_character>
5. <https://geoportal.dane.gov.co/geovisores/territorio/consulta-divipola-division-politico-administrativa-de-colombia/>
6. <https://www.dane.gov.co/files/investigaciones/divipola/divipola2007.pdf>
7. <https://www.datos.gov.co/widgets/gdxc-w37w>
8. <https://muisca.dian.gov.co/WebRutMuisca/visor/formularios/f18/v4/direcciones/direcciones.jsp>
9. <https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#10_admin_level_values_for_specific_countries>
10. <https://postgis.net/docs/ST_Distance.html>
