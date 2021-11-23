# API Use Cases

<http://api.addressforall.org/test/search?_q=CL%20107%2042%20Popular&lim=10>

<http://api.addressforall.org/test/search?_q=Calle%2095%20%2369-61&lim=1>

<http://api.addressforall.org/test/_sql/search>

<http://api.addressforall.org/test/_sql/rpc/search?_q=CL%20107%2042%20Popular&lim=10>

```sql
SELECT api.reverse(-75.486799, 6.194510);  
SELECT api.reverse(-75.486799, 6.194510, 200, 10);
```

<http://api.addressforall.org/test/reverse?lon=-75.486799&lat=6.194510>  
<http://api.addressforall.org/test/get_address?lon=-75.486799&lat=6.194510>

```json
{
  "hint": "If a new function was created in the database with this name and arguments, try reloading the schema cache.",
  "message": "Could not find the api.reverse(lat, lon) function in the schema cache"
}
```

```sql
SELECT api.lookup('CL 1BB #48A ESTE-522 (0130)');  
SELECT api.lookup('443091');
```

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

<https://www.urlencoder.io>
