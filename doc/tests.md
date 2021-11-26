# Tests

<http://api.addressforall.org/test/_sql/search>

<http://api.addressforall.org/test/_sql/rpc/search?_q=CL%20107%2042%20Popular&lim=3>

## Schema Cache Reloading

```batch
co_ba=# NOTIFY pgrst, 'reload schema';
```

## References

1. <https://www.urlencoder.io>
2. <https://postgrest.org/en/stable/schema_cache.html#reloading-with-notify>
