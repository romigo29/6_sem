package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {

	r := mux.NewRouter()
	r.HandleFunc("/rpc", RPCHandler).Methods("POST")

	log.Println("Server started on port 3000")
	err := http.ListenAndServe(":3000", r)
	if err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
