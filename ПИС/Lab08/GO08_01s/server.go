package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/ws", wsHandler)

	log.Println("WebSocket server started on :3000")
	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatal("Server error:", err)
	}
}