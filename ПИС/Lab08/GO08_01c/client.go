package main

import (
	"log"
	"time"

	"github.com/gorilla/websocket"
)

func main() {
	url := "ws://localhost:3000/ws"

	log.Println("Connecting to", url)

	conn, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		log.Fatal("Connection error:", err)
	}

	for i := 1; i <= 5; i++ {
		message := "message " + string(rune(i+'0'))

		log.Println("Sending:", message)

		err := conn.WriteMessage(websocket.TextMessage, []byte(message))
		if err != nil {
			log.Println("Write error:", err)
			return
		}

		_, response, err := conn.ReadMessage()
		if err != nil {
			log.Println("Read error:", err)
			return
		}

		log.Println("Received:", string(response))

		time.Sleep(1 * time.Second)
	}

	log.Println("Client finished work")

	err = conn.WriteMessage(
		websocket.CloseMessage,
		websocket.FormatCloseMessage(websocket.CloseNormalClosure, "bye"),
	)
	if err != nil {
		log.Println("Close write error:", err)
		return
	}

	time.Sleep(100 * time.Millisecond)

	conn.Close()
}
