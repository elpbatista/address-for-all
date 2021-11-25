# API Use Cases

## Full Text Search

### Generic Search

<http://api.addressforall.org/test/search?_q=Calle%2095%20%2369-61&lim=1>

```json
[
  {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [-75.57377, 6.290209]
    },
    "properties": {
      "similarity": 0.28,
      "_id": "57338",
      "address": "CL 95 #69-61",
      "display_name": "Calle 95 #69-61",
      "barrio": "Castilla",
      "comuna": "CASTILLA",
      "municipality": "Antioquia",
      "divipola": "05001",
      "country": "Colombia"
    }
  }
]
```

<http://api.addressforall.org/test/search?_q=CL%20107%2042%20Popular&lim=3>

```json
{
  "type": "FeatureCollection",
  "query": "CL 107 42 Popular",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.548216, 6.296636]
      },
      "properties": {
        "similarity": 0.3148148,
        "_id": "44088",
        "address": "CL 107E #42C-42",
        "display_name": "Calle 107E #42C-42",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.548093, 6.296]
      },
      "properties": {
        "similarity": 0.3148148,
        "_id": "340868",
        "address": "CL 107C #42B-42",
        "display_name": "Calle 107C #42B-42",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.54852, 6.296365]
      },
      "properties": {
        "similarity": 0.3090909,
        "_id": "185990",
        "address": "CL 107D #42D-07",
        "display_name": "Calle 107D #42D-07",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    }
  ]
}
```

#### RPC call

<http://api.addressforall.org/test/_sql/rpc/search?_q=CL%20107%2042%20Popular&lim=3>

```batch
curl -X POST \
  http://api.addressforall.org/test/_sql/rpc/search \
  -H 'Content-Type: application/json' \
  -d '{"_q":"CL 107C #42B-42 Popular", "lim":3}'
```

### Search in a Bounding-box (Recomended!) :rocket:

```batch
curl -X POST \
  http://api.addressforall.org/test/_sql/rpc/search_bounded \
  -H 'Content-Type: application/json' \
  -d '{"_q":"CL 107C #42B-42 Popular", "viewbox":[-75.552, 6.291, -75.543, 6.297], "lim":3}'
```

```json
{
  "type": "FeatureCollection",
  "query": "CL 107C #42B-42 Popular",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.548093, 6.296]
      },
      "properties": {
        "similarity": 0.8076923,
        "_id": "340868",
        "address": "CL 107C #42B-42",
        "display_name": "Calle 107C #42B-42",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.547945, 6.295895]
      },
      "properties": {
        "similarity": 0.71428573,
        "_id": "82402",
        "address": "CL 107C #42B-18",
        "display_name": "Calle 107C #42B-18",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.548163, 6.295952]
      },
      "properties": {
        "similarity": 0.71428573,
        "_id": "18106",
        "address": "CL 107C #42B-47",
        "display_name": "Calle 107C #42B-47",
        "barrio": "Popular",
        "comuna": "POPULAR",
        "municipality": "Antioquia",
        "divipola": "05001",
        "country": "Colombia"
      }
    }
  ]
}
```

### Search Nearby

```batch
curl -X POST \
  http://api.addressforall.org/test/_sql/rpc/search_nearby \
  -H 'Content-Type: application/json' \
  -d '{"_q":"Calle 1BB #48A ESTE-522 El Cerro", "loc":[-75.486799, 6.194510],"radius":200, "lim":3}'
```

```json
{
  "type": "FeatureCollection",
  "query": "Calle 1BB #48A ESTE-522 El Cerro",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-75.4868, 6.194511]
      },
      "properties": {
        "similarity": 0.63829786,
        "distance": 0.13,
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
        "coordinates": [-75.486694, 6.194649]
      },
      "properties": {
        "similarity": 0.63829786,
        "distance": 19.3,
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
        "coordinates": [-75.485823, 6.193292]
      },
      "properties": {
        "similarity": 0.50980395,
        "distance": 173.14,
        "_id": "194489",
        "address": "CL 1BB #48A ESTE-621 (0109)",
        "display_name": "Calle 1BB #48A ESTE-621 (0109)",
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

## Reverse Geocoding

<http://api.addressforall.org/test/reverse?lon=-75.486799&lat=6.194510>

```json
[
  {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [-75.4868, 6.194511]
    },
    "properties": {
      "distance": 0.13,
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
        "coordinates": [-75.4868, 6.194511]
      },
      "properties": {
        "distance": 0.13,
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
        "coordinates": [-75.486694, 6.194649]
      },
      "properties": {
        "distance": 19.3,
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
        "coordinates": [-75.486234, 6.194748]
      },
      "properties": {
        "distance": 67.78,
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
    "coordinates": [-75.4868, 6.194511]
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
