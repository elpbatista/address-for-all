# Definición

Este documento documento presenta la especificación de funcionalidades, y un primer acercamiento al diseño de intracción como resultado de la captura de requisitos...

## Ver con Freddy

Requerimientos:

- ¿Qué tipos de objetos debería devolver el API? _ver Geocodificación_
- ¿Hay Nomenclatura Predial Rural? ¿Es de interés para este proyecto?
- ¿Dónde se obtienen los nombres comunes `commonName` de las vías si es que lo tienen?
- ¿Estamos interesados en llegar algún día hasta la subdivisión del lote: `complemento`?
- ¿El API es de solo lectura o también se debería tener en cuenta la escritura?
- ¿Se planea sanear o consolidar los datos? Alguna consolidadción será necesaria para este proyecto por medio de `materialized views`
- ¿Tenemos a mano algunos casos de uso?
- ¿Hay algún criterio de dimensión del punto `lon` `lat` `offset`? _Vi algo por ahí sobre la distancia entre direciones que es diferente en caso de ser rural o urbana_
- ¿Estamos genrando `IDs` globales para los objetos? _Puede ser que esta sea una pregunta para Cleiton_
- ¿Vamos a referenciar objetos de OSM en caso de que existan? _Por ejemplo si alguien busca CAPITOLIO NACIONAL_
- ¿Qué datos `properties` debe incluir la `response`? Especificar para cada caso _Ver apartado Response_
- ¿El API devolvería solo objetos geográficos `features` o también se ha considerado que devuelva etiquetas como nombres o ids `strings`?

## Endpoints

Un `endpoint` es básicamente una palabra elegante para una URL de un servidor o servicio a través de una API.

Este apartado es un borrardor de especificación del formato de `requests` y `responses` para cada caso de interacción definido por el usario final (Freddy). Se ha tomado como referencia la [documentación](https://developer.lupap.com/documentation) del Geocodificador de archivos y API de geocodificación para Colombia.

### Geocodificación

La respueta es un JSON que incluye una `FeatureCollection` si toca depende de cuán verbosa se quirea hacer.

- `string` ⟹ `FeatureCollection`

#### Direcciones

Response:

- `features.length() = n`
- `Feature.geometry.type = Point`

#### Vías

Response:

- `features.length() = n`
- `Feature.geometry.type = LineString || MultiLineString`

#### Intersecciones

Response:

- `features.length() = n`
- `Feature.geometry.type =` :question:

#### Lugares

Response:

- `features.length() = n`
- `Feature.geometry.type =` :question:

### Geocodificación Inversa

- `Point` ⟹ `FeatureCollection` donde `features.length() = 1` :question:
- `Extent` ⟹ `FeatureCollection`
- `FeatureCollection` ⟹ `FeatureCollection` :rocket:

## Anotaciones

Implementar un mecanismo de validación de entrada `input validation` para prevenier la iyección de SQL `SQL injection`. Esto seguramente será descrito detalladamente en otra parte de la especificación.

:question: ¿Incluir llamadas de `service capability`?

Inside this document, the term "geometry type" refers to seven case-sensitive strings: "Point", "MultiPoint", "LineString", "MultiLineString", "Polygon", "MultiPolygon", and "GeometryCollection".

Nomenclatura Predial Urbana

```text
   vía      placa    complemento
├───────┼─┼────────┼─┼──────────┤
AV 6 BIS # 28 NORTE - 09 APT 201
          ├────────┼─┼──┤
             cruce    d
```

## Response

:fire: Tomado de Lupap Developers. Debe ser adaptado a A4A

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

## Referencias

1. <https://developer.lupap.com>
2. <https://geojson.org>
3. <https://en.wikipedia.org/wiki/Box-drawing_character>
