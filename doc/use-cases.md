# API Use Cases

<http://api.addressforall.org/test/search?_q=CL%20107%2042%20Popular&lim=10>

<http://api.addressforall.org/test/search?_q=Calle%2095%20%2369-61&lim=1>

<http://api.addressforall.org/test/_sql/rpc/search?_q=CL%20107%2042%20Popular&lim=10>

## Reverse Geocoding

<http://api.addressforall.org/test/reverse?lon=-75.486799&lat=6.194510>  

```json
[
  {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [
        -75.4868,
        6.194511
      ]
    },
    "properties": {
      "_id": "443091",
      "address": "CL 1BB #48A ESTE-522 (0130)",
      "display_name": "Calle 1BB #48A ESTE-522 (0130)",
      "barrio": "El Cerro",
      "comuna": "SANTA ELENA",
      "municipality": "Antioquia",
      "divipola": "05266",
      "country": "Colombia"
    }
  }
]
```

<http://api.addressforall.org/test/reverse?lon=-75.486799&lat=6.194510&radius=200&lim=3>  

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          -75.4868,
          6.194511
        ]
      },
      "properties": {
        "_id": "443091",
        "address": "CL 1BB #48A ESTE-522 (0130)",
        "display_name": "Calle 1BB #48A ESTE-522 (0130)",
        "barrio": "El Cerro",
        "comuna": "SANTA ELENA",
        "municipality": "Antioquia",
        "divipola": "05266",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          -75.486694,
          6.194649
        ]
      },
      "properties": {
        "_id": "360091",
        "address": "CL 1BB #48A ESTE-522 (0135)",
        "display_name": "Calle 1BB #48A ESTE-522 (0135)",
        "barrio": "El Cerro",
        "comuna": "SANTA ELENA",
        "municipality": "Antioquia",
        "divipola": "05266",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          -75.486234,
          6.194748
        ]
      },
      "properties": {
        "_id": "195150",
        "address": "CR 51 ESTE #1BB-149 (0103)",
        "display_name": "Circunvalar 51 ESTE #1BB-149 (0103)",
        "barrio": "El Cerro",
        "comuna": "SANTA ELENA",
        "municipality": "Antioquia",
        "divipola": "05266",
        "country": "Colombia"
      }
    }
  ]
}
```

## Address Lookup

<http://api.addressforall.org/test/lookup?address=443091>  
<http://api.addressforall.org/test/lookup?address=CL%201BB%20%2348A%20ESTE-522%20%280130%29>

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [
      -75.4868,
      6.194511
    ]
  },
  "properties": {
    "_id": 443091,
    "city": "Envigado",
    "cruce": "CL 48A ESTE",
    "barrio": "El Cerro",
    "comuna": "SANTA ELENA",
    "address": "CL 1BB #48A ESTE-522 (0130)",
    "country": "Colombia",
    "divipola": "05266",
    "display_name": "Calle 1BB #48A ESTE-522 (0130)",
    "municipality": "Antioquia"
  }
}
```

## References

1. <https://www.urlencoder.io>