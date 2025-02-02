# kafka-debezium-lightsail-postgresql


## check connector plugin of debezium

```
curl -X GET http://localhost:8083/connector-plugins
```

## Create Publication

```
CREATE PUBLICATION dbz_publication_users FOR TABLE users  WITH (publish = 'insert, update, delete');
```

## List connectors

```
curl -X GET "http://127.0.0.1:8083/connectors"
```


## check status of connector

```
curl -X GET http://127.0.0.1:8083/connectors/postgres-cdc-connector/status
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

