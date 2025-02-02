# kafka-debezium-lightsail-postgresql


## check connector plugin of debezium

```
curl -X GET http://localhost:8083/connector-plugins
```



## fix error 


issue:
```
Connector configuration is invalid and contains the following 1 error(s):\nError while validating connector config: Postgres server wal_level property must be 'logical' but is: 'replica'
```

solution:
```
   ALTER SYSTEM SET wal_level = 'logical';
```