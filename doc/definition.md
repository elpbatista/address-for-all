# Definición

Este documetno es un borrador por lo que está sujeto a cambios, enmiendas, adiciones y correcciones hasta que todos quedemos conformes y se comparta la versión final a finales de esta semana, la cual vamos a usar como referencias para las posteriores etapas del proyecto.  
Aquí deberá quedar plasmado y descrito cada uno de los requerimientos, los que se retringirán al alcance del proyecto hasta donde ha sido concebido.

## URL

Esta URL es usada solo a los efectos de este documento. Debe ser sistituida por la dirección donde va a estar alejado el servicio.

`http(s)://api.address4all.org/`

## Endpoints

A continuación se definen los siguientes endpoints:

- /search ⟹ Obtener direcciones a partir de texto libre y parametrizado (búsqueda estructurada)
- /reverse ⟹ Obtener direcciones a partir de su localización
- /lookup ⟹ Obtener direcciones a partir de su id (CID?)
- /doc, /help ⟹ Consultar la documentación (devuelve este documento más o menos)

Una propuesta para facilitar el uso por parte de los desarrolladores es si se invoca `URL+endpoint` sin parámetros, o sea nada a partir de `?` devuelver una especie de capability. Una docuemto donde se especifique qué contiene cada parámetro y qué se espera obtener como respuesta.

### Búsqueda de Direcciones o Geocodificación

      https://api.address4all.org/search?<params>

La consulta puede especificarse con los siguientes parámetros:

- `q=<query>` Cadena de texto libre para buscar
- `a=<address>` Dirección estandarizada según la Nomenclatura Predial Urbana

Búsqueda estructurada: Añadir parámetros separados por coma `,`. Estos son algunos de los propuestos por Nominatim, habría que mirar los niveles administrativos y otras propiedades para adaptarlos a nuesto caso.

- `city=<city>` ⟹ `admin_level=7`
- `county=<county>`
- `state=<state>` ⟹ En Colombia Departamento `admin_level=4`
- `postalcode=<postalcode>`

Parámetros adicionales: Su objetvo es acotar el alcance de la búsqueda así como la cantidad de resultados.

- `limit=<integer>` Cantidad de resultados retornados.
- `viewbox|bbox=<lon1>,<lat1>,<lon2>,<lat2>`

### Recuperación de direcciones

La recuperación permite obetener una o varias direcciones a partir de su CID.

El API de búsqueda tiene el siguiente formato:

      https://api.address4all.org/lookup?cids=<value>,…,<value>&<params>

- `cids=<value>,…,<value>`

### Geocodificación Inversa

      https://api.address4all.org/reverse?lon=<value>&lat=<value>&<params>

- `lon=<value>`
- `lat=<value>`
- `offset=<vlue>` Default `radius=3m`
- `limit=<velue>` Junto con `offset` _(las N direcciones más cercanas)_
- `geom=<geometry>` :question:

### Obeter una dirección a partir de un punto

`https://api.address4all.org/reverse?lon=-74.04659&lat=4.72014`

Devuelve la dirección más cercana al punto `(lon,lat)` que recibe como parámetro. La operación está restringida al radio en metros que se especifica como `offset`, cuyo valor por defecto es 3.

### Obtener las N direcciones más cercanas al punto

Devuelve las cantidad de direcciones especificadas en `limit` más cercana al punto `(lon,lat)` que recibe como parámetro. La operación está restringida al radio en metros que se especifica como `offset`. Los parámetros `offset` y `limit` podrían tener restricciones de valor máximo `max_value=<integer>`

`https://api.address4all.org/reverse?lon=-74.04659&lat=4.72014&offset=50&limit=10`

### Consulta a nivel de servicio

A continuación aparece una simulación de como podría ser la consulta a la base de datos de PostgreSQL+QGIS donde está soportado el servicio. Los etiquetas no son precisas, `"address"` y `"addresses"` no necesariramente se corresponden con la BD, esto es solo un ejemplo. También podrían probarse otros métodos en pos de encontrar el desempeño óptimo.

```sql
SELECT "address", ST_Distance(geom, ST_MakePoint(lon, lat)) AS distance
FROM "addresses"
WHERE  distance <= offset
ORDER BY distance
LIMIT 1;
```

## Consultas al API

- **GET** `/search`
- **GET|POST** `/search?q=<string>&[city=<string>]&[country=<string>]&[state=<string>]&[postalcode=<string>]&[limit=<integer>]&viewbox=<integer>,<integer>,<integer>,<integer>]`
- **GET|POST** `/search?a=<string>&[city=<string>]&[country=<string>]&[state=<string>]&[postalcode=<string>]&[limit=<integer>]&viewbox=<integer>,<integer>,<integer>,<integer>]`
- **GET** `/lookup`
- **GET|POST** `/lookup?cids=<string>[,…,<string>]`
- **GET** `/reverse`
- - **GET|POST** `/reverse?lon=<integer>&lat=<integer>&{offset=3}&{limit=1}`
- **GET|POST** `/reverse?lon=<integer>&lat=<integer>&[offset=<integer>]&[limit=<integer>]`
- **POST** `/reverse?geom=<object>&[limit=<integer>]` :question:
- **GET** `/doc`
- **GET** `/help`

## Respuesta

- El API devuelve **en todos los casos** una colección de objetos geográficos `FeatureCollection` codificada en forma de GeoJSON. Cada dirección está representada por un punto o sea un objeto del tipo `Feature` con `Feature.geometry.type = "Point"` y un grupo de propiedades `properties` que todavía requieren cierto grado de refinamiento.
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
  "licence": "Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright",
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
        "common_name": "AVENIDA SANTA BARBARA",
        "official_name": "",
        "alt_name": "",
        "old_name": "",
        "address": "AK 19 # 135 - 30",
        "housename": "Edificio de las Naciones",
        "display_name": "Avenida Carrera Santa Bárbara # 135 - 30",
        "city": "",
        "state": "",
        "postcode": "110121",
        "country": "Colombia",
        "country_code": "co",
        "divipolacode": "15001001",
        "admin1": "N/A",
        "admin2": "Colombia",
        "admin3": "",
        "admin4": "",
        "admin4": "",
        "admin5": "",
        "admin6": "",
        "admin7": "",
        "admin8": "",
        "admin9": "",
        "admin10": ""
      }
    }
  ]
}
```

## Notas

1. Es imperativo definir una convención para las etiquetas, los nombres de las propiedades, funciones, variables, incluso para los contenidos. Por favor agregar la referencia si es que ya existe.
2. Se recomienda truncar los valores de `lon`, `lat` a 5 (cinco, five) lugares decimales. Las direcciones postales están en el orden de los metros por lo que usar una mayor precisión para representarlas es totalmente innecesario. Esto reduciría considerablemente el tamaño de las geometrías almacenadas impactando de manera significativa el cálculo de operaciones espaciales, haciéndolo mucho más ágil/eficiente.

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

### Niveles administrativos

Tomado de la especificación de uso de los Niveles Administrativos de OpenStreetMap. Se puede consultar [aquí](https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level.3D.2A_Country_specific_values) `Ctrl+F Colombia`

| `admin_level`    | Divisiones Adminstrativas de Colombia     | Alternativa |
| ---------------- | ----------------------------------------- | ----------- |
| `admin_level=1`  | N/A                                       |             |
| `admin_level=2`  | País                                      | `country`   |
| `admin_level=3`  | Región de planeación administrativa       |             |
| `admin_level=4`  | Departamento                              | `state`     |
| `admin_level=5`  | Provincia                                 |             |
| `admin_level=6`  | Municipio                                 | `city`      |
| `admin_level=7`  | Urbano: Ciudad, Rural: Corregimiento      |             |
| `admin_level=8`  | Urbano: Localidad o Comuna, Rural: Vereda |             |
| `admin_level=9`  | Urbano: Barrio, Rural: N/A                |             |
| `admin_level=10` | N/A (Barrios en Bogotá, también UPZs)     |             |

### Convenciones

#### Notaciones

- corchetes `[opcional]`
- corchetes angulares `<requerido>`
- llaves `{valores por defecto}`
- paréntesis `(información diversa)`

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
11. <https://wiki.openstreetmap.org/wiki/Key:admin_level>
12. <https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level.3D.2A_Country_specific_values>
13. <https://wiki.openstreetmap.org/wiki/ES:Colombia/Gu%C3%ADa_para_mapear>
