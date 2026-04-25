package main

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true 
	},
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Incoming connection:", r.RemoteAddr)

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade error:", err)
		return
	}
	defer func() {
		conn.Close()
		log.Println("Connection closed:", r.RemoteAddr)
	}()

	for {
		msgType, msg, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsCloseError(err, websocket.CloseNormalClosure) {
				log.Println("Client closed connection normally")
			} else {
				log.Println("Client disconnected:", err)
			}
			break
		}

		if msgType == websocket.CloseMessage {
			log.Println("Received close frame")
			break
		}

		log.Printf("Received: %s\n", msg)

		response := "from server: " + string(msg)

		err = conn.WriteMessage(msgType, []byte(response))
		if err != nil {
			log.Println("Write error:", err)
			break
		}
	}
}
