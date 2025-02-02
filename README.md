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



 Debugging PostgreSQL Logical Replication & Debezium
Logical replication in PostgreSQL allows Debezium to track changes and publish them to Kafka. If Debezium isn't capturing changes, these SQL commands help diagnose the problem.

✅ 1. Check if a Publication Exists

```
SELECT * FROM pg_publication;
```

📌 Explanation
Lists all active publications in PostgreSQL.
Publications define which tables PostgreSQL should send changes from.
🔍 Expected Output
```
 pubname  | pubowner | puballtables | pubinsert | pubupdate | pubdelete | pubtruncate 
----------+---------+-------------+----------+----------+----------+------------
 debezium |  16384  | f           | t        | t        | t        | f
(1 row)
```

❌ If No Publication Exists
Create one:
```
CREATE PUBLICATION debezium FOR ALL TABLES;
```

✅ 2. Check if a Replication Slot Exists
```
SELECT * FROM pg_replication_slots;
```
📌 Explanation
Lists replication slots, which track changes for Debezium.
Debezium uses a logical replication slot to receive WAL (Write-Ahead Log) updates.
🔍 Expected Output
```
 slot_name      | plugin  | slot_type | active | restart_lsn 
---------------+---------+-----------+--------+-------------
 debezium_slot | pgoutput | logical  | t      | 0/16B40D0
```

❌ If the Slot is Missing
Create a new one:

```
SELECT pg_create_logical_replication_slot('debezium_slot', 'pgoutput');
```

✅ 3. Check if Replication is Active
```
SELECT * FROM pg_stat_replication;
```

📌 Explanation
Shows active replication connections.
If Debezium is working, you should see a row indicating replication is streaming.
🔍 Expected Output
```
 pid  | application_name | state  | sent_lsn | write_lsn | flush_lsn | replay_lsn
------+------------------+--------+----------+----------+----------+-----------
  56  | debezium        | streaming | 0/16B40D0 | 0/16B40D0 | 0/16B40D0 | 0/16B40D0
(1 row)
```

❌ If No Rows Appear
Debezium is not connected.

✅ Fix: Restart Debezium

```
docker-compose restart connect
```
✅ 4. Check If Changes Are Being Captured

```
SELECT * FROM pg_logical_slot_peek_changes('debezium_slot', NULL, 10);
```
📌 Explanation
Manually views recent changes in the replication slot.
If no rows appear, PostgreSQL is not sending changes to Debezium.
🔍 Expected Output

```
 lsn  | xid | data
------+-----+--------------------------------------------------
 0/16B40D0 | 789 | {"op": "c", "table": "users", "id": 3, "name": "Charlie"}
```

❌ If No Rows Appear
Check if WAL logging is enabled.
Ensure the table is in the publication.
✅ 5. Ensure WAL Level is logical

```
SHOW wal_level;
```

📌 Explanation
Ensures PostgreSQL WAL-level is set to logical (needed for Debezium).
🔍 Expected Output

```
 wal_level 
-----------
 logical
```

❌ If Output is Not logical
Enable logical replication:

```
ALTER SYSTEM SET wal_level = 'logical';
SELECT pg_reload_conf();
Restart PostgreSQL:
```


```
sudo systemctl restart postgresql
```

🚀 Final Debugging Checklist
1️⃣ Check if a publication exists
```
SELECT * FROM pg_publication;
```
2️⃣ Verify if the table is included in the publication
```
SELECT * FROM pg_publication_tables WHERE pubname = 'debezium';
```
3️⃣ Ensure a replication slot exists

```
SELECT * FROM pg_replication_slots;
```

4️⃣ Check if Debezium is actively streaming

```
SELECT * FROM pg_stat_replication;
```

5️⃣ Manually check if changes are being tracked

```
SELECT * FROM pg_logical_slot_peek_changes('debezium_slot', NULL, 10);
```

6️⃣ Verify if Kafka receives the messages

```
kafka-console-consumer --bootstrap-server kafka:9092 --topic CDC_POSTGRES --from-beginning
```