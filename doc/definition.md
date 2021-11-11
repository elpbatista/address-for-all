# Definición <!-- omit in toc -->

Este documetno es un borrador por lo que está sujeto a cambios, enmiendas, adiciones y correcciones hasta que todos quedemos conformes y se comparta la versión final a finales de esta semana, la cual vamos a usar como referencias para las posteriores etapas del proyecto.  
Aquí deberá quedar plasmado y descrito cada uno de los requerimientos, los que se retringirán al alcance del proyecto hasta donde ha sido concebido.

- [1. URL](#1-url)
- [2. Endpoints](#2-endpoints)
  - [2.1. Búsqueda de Direcciones](#21-búsqueda-de-direcciones)
    - [2.1.1. Especificación de formato](#211-especificación-de-formato)
    - [2.1.2. Búsqueda estructurada](#212-búsqueda-estructurada)
    - [2.1.3. Parámetros adicionales](#213-parámetros-adicionales)
  - [2.2. Geocodificación](#22-geocodificación)
  - [2.3. Geocodificación Inversa](#23-geocodificación-inversa)
  - [2.4. Obeter una dirección a partir de un punto](#24-obeter-una-dirección-a-partir-de-un-punto)
  - [2.5. Obtener las N direcciones más cercanas al punto](#25-obtener-las-n-direcciones-más-cercanas-al-punto)
  - [2.6. Consulta espacial a nivel de servicio](#26-consulta-espacial-a-nivel-de-servicio)
- [3. Consultas al API](#3-consultas-al-api)
- [4. Respuesta](#4-respuesta)
  - [4.1. Nombres y direcciones estandarizados](#41-nombres-y-direcciones-estandarizados)
  - [4.2. Direcciones georeferenciadas y sus metadatos](#42-direcciones-georeferenciadas-y-sus-metadatos)
- [5. Micro Servicios](#5-micro-servicios)
  - [5.1. Búsqueda Espacial](#51-búsqueda-espacial)
  - [5.2. Nombre - Forma Canónica](#52-nombre---forma-canónica)
  - [5.3. Dirección - Metadato](#53-dirección---metadato)
- [6. Notas](#6-notas)
  - [6.1. Nomenclatura Predial Urbana](#61-nomenclatura-predial-urbana)
  - [6.2. Estandarización de Direcciones](#62-estandarización-de-direcciones)
  - [6.3. Direcciones Atípicas](#63-direcciones-atípicas)
  - [6.4. Direcciones Postales](#64-direcciones-postales)
  - [6.5. Niveles administrativos](#65-niveles-administrativos)
  - [6.6. Convenciones](#66-convenciones)
    - [6.6.1. Notaciones](#661-notaciones)
- [7. Referencias](#7-referencias)

## 1. URL

Esta URL es usada solo a los efectos de este documento. Debe ser sistituida por la dirección donde va a estar alejado el servicio.

`http(s)://api.address4all.org/`

## 2. Endpoints

A continuación se definen los siguientes endpoints:

- /search ⟹ Obtener direcciones a partir de texto libre y parametrizado (búsqueda estructurada)
- /reverse ⟹ Obtener direcciones a partir de su localización
- /lookup ⟹ Obtener direcciones a partir de su id o su forma canónica (CID?)
- /doc, /help ⟹ Consultar la documentación (devuelve este documento más o menos)

Una propuesta para facilitar el uso por parte de los desarrolladores es si se invoca `URL+endpoint` sin parámetros, o sea nada a partir de `?` devuelver una especie de capability. Una docuemto donde se especifique qué contiene cada parámetro y qué se espera obtener como respuesta.

### 2.1. Búsqueda de Direcciones

      https://api.address4all.org/search?<params>

- `q=<query>` Cadena de texto libre para buscar

#### 2.1.1. Especificación de formato

- `format=<value>` Formato de salida. Defautl `json`, si `geojson` incluye geocodificación

#### 2.1.2. Búsqueda estructurada

Lista de parámetros separados por coma `,`.

- `city=<city>` ⟹ `admin_level=7`
- `county=<county>`
- `state=<state>` ⟹ En Colombia Departamento `admin_level=4`
- `postalcode=<postalcode>`

#### 2.1.3. Parámetros adicionales

Su objetvo es acotar el alcance de la búsqueda así como la cantidad de resultados.

- `limit=<integer>` Cantidad de resultados retornados.
- `viewbox|bbox=<lon1>,<lat1>,<lon2>,<lat2>`
- `bounded=[0|1]`
- `near=<lon>,<lat>`
- `offset=<value>`
- `in=<geometry>` :question:
- `out=<geometry>` :question:

### 2.2. Geocodificación

Devuelve una o varias direcciones a partir de su CID.

      https://api.address4all.org/lookup?cids=<value>,…,<value>&<params>

- `cids=<value>,…,<value>`

Devuelve una o varias direcciones a partir de la forma canónica o estandraizada segun la Nomenclatura Predial Urbana.

      https://api.address4all.org/lookup?cids=<value>,…,<value>&<params>

- `cads=<value>,…,<value>`

### 2.3. Geocodificación Inversa

      https://api.address4all.org/reverse?lon=<value>&lat=<value>&<params>

- `lon=<value>`
- `lat=<value>`
- `offset=<value>` Default `radius=3m`
- `limit=<value>` Junto con `offset` _(las N direcciones más cercanas)_
- `geom=<geometry>` :question:

### 2.4. Obeter una dirección a partir de un punto

`https://api.address4all.org/reverse?lon=-74.04659&lat=4.72014`

Devuelve la dirección más cercana al punto `(lon,lat)` que recibe como parámetro. La operación está restringida al radio en metros que se especifica como `offset`, cuyo valor por defecto es 3.

### 2.5. Obtener las N direcciones más cercanas al punto

Devuelve las cantidad de direcciones especificadas en `limit` más cercana al punto `(lon,lat)` que recibe como parámetro. La operación está restringida al radio en metros que se especifica como `offset`. Los parámetros `offset` y `limit` podrían tener restricciones de valor máximo `max_value=<integer>`

`https://api.address4all.org/reverse?lon=-74.04659&lat=4.72014&offset=50&limit=10`

### 2.6. Consulta espacial a nivel de servicio

A continuación aparece una simulación de como podría ser la consulta a la base de datos de PostgreSQL+QGIS donde está soportado el servicio. Los etiquetas no son precisas, `"address"` y `"addresses"` no necesariramente se corresponden con la BD, esto es solo un ejemplo. También podrían probarse otros métodos en pos de encontrar el desempeño óptimo.

```sql
SELECT "address", ST_Distance(geom, ST_MakePoint(lon, lat)) AS distance
FROM "addresses"
WHERE  distance <= offset
ORDER BY distance
LIMIT 1;
```

## 3. Consultas al API

- **GET** `/search`
- **GET|POST** `/search?q=<string>&[city=<string>]&[country=<string>]&[state=<string>]&[postalcode=<string>]&[limit=<integer>]&[viewbox=<integer>,<integer>,<integer>,<integer>]&[bounded=1]`
- **GET|POST** `/search?q=<string>&lon=<integer>&lat=<integer>&[offset=<integer>]&[limit=<integer>]`
- **GET** `/lookup`
- **GET|POST** `/lookup?cids=<string>[,…,<string>]`
- **GET|POST** `/lookup?cads=<string>[,…,<string>]`
- **GET** `/reverse`
- **GET|POST** `/reverse?lon=<integer>&lat=<integer>&{offset=3}&{limit=1}`
- **GET|POST** `/reverse?lon=<integer>&lat=<integer>&[offset=<integer>]&[limit=<integer>]`
- **POST** `/reverse?geom=<object>&[limit=<integer>]` :question:
- **GET** `/doc`
- **GET** `/help`

## 4. Respuesta

### 4.1. Nombres y direcciones estandarizados

Cuando `format=json`, valor por defecto en la búsqueda de direcciones, se devuelve una arreglo de objetos con las propiedades `address` y `display_name` de las direcciones que satisfacen los criterios de la búsqueda.

Como `address` puede repetirse en cada una de las ciudades de Colombia, especialmente cuando la vía principal y la vía generadora se identifican con números pequeños, hay que incluir alguna otra información que sirva para desambiguar. Podría ser solamente el `CID` pero todavía es necesario algo comprensible por humanos para mostrarle al usuario final que debe seleccionar cuál de los resultados devueltos es el que se corresponde con su búsqueda. La propuesta hasta ahora es inculuir `city`, `state` y `country` pero está abierta a modificaciones. (validar) :question:

```json
[
  {
    "CID": "",
    "address": "AK 19 # 135 - 30",
    "display_name": "Avenida Carrera Santa Bárbara # 135 - 30",
    "city": "El Libano",
    "state": "Tolima",
    "country": "Colombia"
  }
]
```

### 4.2. Direcciones georeferenciadas y sus metadatos

- Cuando `format=geojson` el API devuelve una colección de objetos geográficos `FeatureCollection` codificada en forma de GeoJSON. Cada dirección está representada por un punto o sea un objeto del tipo `Feature` con `Feature.geometry.type = "Point"` y un grupo de propiedades `properties` que todavía requieren cierto grado de refinamiento.
  - `features.length() = 0`: la búnqueda no arrojó ningún resultado
  - `features.length() > 0`: la búnsqueda ha sido exitosa.
    - `features.length() = 1`: el resultado es exacto.
    - `features.length() > 1`: se necesita desambigüación.
- Se añadió el código **DIVIPOLA** por recomendación de Freddy por ser de uso muy frecuente entre los locales, inlcuso por encima del Código Postal.
- Los niveles administrativos requieren una pasada de mano con mayor atención. No estoy seguro si se quiere guardar alguna compatibilidad con el resto de los sets de datos del proyecto ¿a quién lse lee puede preguntar?
- Teniendo en cuenta que las vías pueden ser conocidad o nombradad de varias formas recogidas en el apartado [Nombres de Calles](https://wiki.openstreetmap.org/wiki/ES:Colombia/Gu%C3%ADa_para_mapear#Nombres_de_calles) de la Guía para Mapear de OSM-Colombia, se propone incluir las propiedades `oficial_name`, `alt_name` y `old_name`.
- En el documento antes mencionado se propone el uso de `housename` para identificar edificaciones, granjas, colegios que tienen un nombre oficial o ampliamente utilizado.

```json
{
  "type": "FeatureCollection",
  "version": "",
  "licence": "ODbL 1.0",
  "query": "Calle 6 # 12-70",
  "limit": 1,
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-74.04659, 4.72014]
      },
      "properties": {
        "CID": "",
        "attribution": "geoapps",
        "way_common_name": "",
        "way_official_name": "",
        "way_alt_name": "",
        "way_old_name": "",
        "housename": "",
        "address": "CL 6 # 12-70",
        "display_name": "Calle 6 # 12-70",
        "city": "El Libano",
        "state": "Tolima",
        "country": "Colombia",
        "country_code": "co",
        "postcode": "731040",
        "divipolacode": "73411",
        "admin1": "N/A",
        "admin2": "Colombia",
        "admin3": "",
        "admin4": "Tolima",
        "admin5": "Provincia de los Nevados",
        "admin6": "Líbano",
        "admin7": "",
        "admin8": "Comuna 3",
        "admin9": "El Centro",
        "admin10": ""
      }
    }
  ]
}
```

## 5. Micro Servicios

### 5.1. Búsqueda Espacial

Devuelve direcciones a partir de una cadena de texto libre. La búsqueda puede ser acotada a través de parámetros y operacione espaciales

### 5.2. Nombre - Forma Canónica

Devuelve formas canónicas ej: Avenida Santa Bárbara - AK 19

### 5.3. Dirección - Metadato

Devuelve el metadato a partir de na dirección estandarizada

## 6. Notas

1. Es imperativo definir una convención para las etiquetas, los nombres de las propiedades, funciones, variables, incluso para los contenidos. Por favor agregar la referencia si es que ya existe.
2. Se recomienda truncar los valores de `lon`, `lat` a 5 (cinco, five) lugares decimales. Las direcciones postales están en el orden de los metros por lo que usar una mayor precisión para representarlas es totalmente innecesario. Esto reduciría considerablemente el tamaño de las geometrías almacenadas impactando de manera significativa el cálculo de operaciones espaciales, haciéndolo mucho más ágil/eficiente.
3. Esplorar otras consultas espaciales a partir de nuevos casos de uso y proponer endpoints para resolverlas.
4. Va a ser preciso diseñar consultas de prueba para estimar la calidad de los datos y probablemente generar vistas consolidadas para soportar los micro servicios.
5. Definir a qué nivel vamos a incluir la `attribution`. ¿Se especificará la fuente de cada dirección individualmente o hay algún criterio para asignarla por lotes?

### 6.1. Nomenclatura Predial Urbana

```text
   vía          placa  complemento
├──────────────┼─────┼───────┤
Calle 6 NORTE # 12-70 APT 201
                ├─┼┼─┤
             cruce    distancia aproximada en metros
```

- `vía` se corresponde con la vía principal.
- `cruce` también aparece como vía generadora.

### 6.2. Estandarización de Direcciones

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

### 6.3. Direcciones Atípicas

Existen las direcciones atípicas, que no tienen la estructura descrita anteriormente. Los siguientes son ejemplos de direcciones atípicas:

- Vereda Guayabal Lote 6 Casa 2
- Km 5 Via La Calera Lote 101
- Urbanización Villa Irina Manzana F Lote 9
- Urbanización Villa de la Victoria Casa 12

### 6.4. Direcciones Postales

Rachel Arrieta  
Calle 1 Norte #13-55 Apto. 902 `display_name`  
Edificio Torre Alta `housename`  
Fundadores 630004 `nombre_bar` _(Barrio)_ `postcode`  
Armenia, Quindío `city` _(Municipio)_, `state` _(Departamento)_  
Colombia `country`  
Teléfono +57 320-302-1734

### 6.5. Niveles administrativos

Tomado de la especificación de uso de los Niveles Administrativos de OpenStreetMap. Se puede consultar [aquí](https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level.3D.2A_Country_specific_values) `Ctrl+F Colombia`

| `admin_level`    | Divisiones Adminstrativas de Colombia     | Alternativa  |
| ---------------- | ----------------------------------------- | ------------ |
| `admin_level=1`  | N/A                                       |              |
| `admin_level=2`  | País                                      | `country`    |
| `admin_level=3`  | Región de planeación administrativa       |              |
| `admin_level=4`  | Departamento                              | `state`      |
| `admin_level=5`  | Provincia                                 |              |
| `admin_level=6`  | Municipio                                 | `city`       |
| `admin_level=7`  | Urbano: Ciudad, Rural: Corregimiento      |              |
| `admin_level=8`  | Urbano: Localidad o Comuna, Rural: Vereda | `nombre_com` |
| `admin_level=9`  | Urbano: Barrio, Rural: N/A                | `nombre_bar` |
| `admin_level=10` | N/A (Barrios en Bogotá, también UPZs)     |              |

Consulta para obtener algunos niveles administrativos de los datos de OSM a partir de las direcciones disponibles.

```SQL
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
```

Resultado de la consulta.

| `divipola` | `city`       | `state`   | `country` |
| ---------- | ------------ | --------- | --------- |
| 05656      | San Jerónimo | Antioquia | Colombia  |
| 05615      | Rionegro     | Antioquia | Colombia  |
| 05001      | Medellín     | Antioquia | Colombia  |
| 05266      | Envigado     | Antioquia | Colombia  |
| 05088      | Bello        | Antioquia | Colombia  |
| 05318      | Guarne       | Antioquia | Colombia  |
| 05360      | Itagüí       | Antioquia | Colombia  |
| 05380      | La Estrella  | Antioquia | Colombia  |

### 6.6. Convenciones

#### 6.6.1. Notaciones

- corchetes `[opcional]`
- corchetes angulares `<requerido>`
- llaves `{valores por defecto}`
- paréntesis `(información diversa)`

## 7. Referencias

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
11. <https://wiki.openstreetmap.org/wiki/Key:admin_level>
12. <https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level.3D.2A_Country_specific_values>
13. <https://wiki.openstreetmap.org/wiki/ES:Colombia/Gu%C3%ADa_para_mapear>
14. <https://github.com/geocoders/geocodejson-spec/tree/master/draft>
15. <https://jqueryui.com/autocomplete/>
16. <https://adresse.data.gouv.fr/api-doc/adresse>
