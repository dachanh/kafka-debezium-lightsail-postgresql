#!/bin/bash

# Kafka Connect REST API URL
KAFKA_CONNECT_URL="http://127.0.0.1:8083/connectors"

# Connector Name
CONNECTOR_NAME="postgres-cdc-connector"

# Check if the connector exists
EXISTING_CONNECTOR=$(curl -s -o /dev/null -w "%{http_code}" "$KAFKA_CONNECT_URL/$CONNECTOR_NAME")

if [ "$EXISTING_CONNECTOR" -eq 200 ]; then
  echo "🔹 Connector $CONNECTOR_NAME found. Deleting..."
  curl -X DELETE "$KAFKA_CONNECT_URL/$CONNECTOR_NAME"

  # Wait for deletion
  sleep 5

  # Verify deletion
  CHECK_DELETED=$(curl -s -o /dev/null -w "%{http_code}" "$KAFKA_CONNECT_URL/$CONNECTOR_NAME")
  if [ "$CHECK_DELETED" -eq 404 ]; then
    echo "✅ Connector $CONNECTOR_NAME deleted successfully!"
  else
    echo "❌ Failed to delete the connector."
  fi
else
  echo "⚠️ Connector $CONNECTOR_NAME does not exist."
fi
