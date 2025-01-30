package main

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/segmentio/kafka-go"
)

type CDCEvent struct {
	Op    string                 `json:"op"`    // "c" (create), "u" (update), "d" (delete)
	Table string                 `json:"table"` // Table name
	Data  map[string]interface{} `json:"after"` // Changed data
}

func main() {
	// Kafka configuration
	kafkaReader := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  []string{"localhost:9092"},
		Topic:    "dbserver1.public.users",
		GroupID:  "cdc-consumer-group",
		MaxBytes: 10e6, // 10MB max per message
	})

	log.Println("Kafka CDC Consumer started... Listening for messages")

	for {
		msg, err := kafkaReader.ReadMessage(context.Background())
		if err != nil {
			log.Fatal("Error reading message:", err)
		}

		var event CDCEvent
		if err := json.Unmarshal(msg.Value, &event); err != nil {
			log.Println("Failed to parse event:", err)
			continue
		}

		log.Println("Received CDC Event:", event)

		// if url, ok := event.Data["presigned_url"].(string); ok {
		// 	go downloadFile(url)
		// }

		time.Sleep(1 * time.Second)
	}
}

// func downloadFile(url string) {
// 	resp, err := http.Get(url)
// 	if err != nil {
// 		log.Println("Failed to download file:", err)
// 		return
// 	}
// 	defer resp.Body.Close()

// 	log.Println("Successfully downloaded file from:", url)
// }
