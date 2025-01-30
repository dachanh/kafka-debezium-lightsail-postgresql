down:
	docker-compose down

build:
	docker-compose up --build -d

up:
	docker-compose up -d

create-topic:
	docker exec -it kafka kafka-topics --create --topic CDC_POSTGRES --bootstrap-server kafka:9092 --partitions 3 --replication-factor 1
