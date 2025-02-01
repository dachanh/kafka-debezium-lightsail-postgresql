#!/bin/bash

# Kafka Connect REST API URL
KAFKA_CONNECT_URL="http://127.0.0.1:8083/connectors"

# Connector Name
CONNECTOR_NAME="postgres-cdc-connector"

# Check if the connector already exists
EXISTING_CONNECTOR=$(curl -s -o /dev/null -w "%{http_code}" "$KAFKA_CONNECT_URL/$CONNECTOR_NAME")

if [ "$EXISTING_CONNECTOR" -eq 200 ]; then
  echo "Connector $CONNECTOR_NAME already exists. Deleting it first..."
  curl -X DELETE "$KAFKA_CONNECT_URL/$CONNECTOR_NAME"
  sleep 5
fi

# Register the new Debezium Connector
echo "Registering Debezium Connector for PostgreSQL..."
curl -X POST "$KAFKA_CONNECT_URL" -H "Content-Type: application/json" -d '{
  "name": "'"$CONNECTOR_NAME"'",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "debezium_user",
    "database.password": "debezium_pass",
    "database.dbname": "debezium_db",
    "database.server.name": "dbserver1",
    "table.include.list": "public.users",
    "plugin.name": "pgoutput",
    "slot.name": "debezium_slot",
    "publication.name": "dbz_publication",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "schema-changes.users",
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "false",
    "value.converter.schemas.enable": "false"
  }
}'

# Check if the connector was successfully created
if [ $? -eq 0 ]; then
  echo "✅ Debezium PostgreSQL CDC Connector registered successfully!"
else
  echo "❌ Failed to register the connector."
fi
