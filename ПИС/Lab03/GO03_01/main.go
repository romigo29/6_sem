package main

import (
	"log"
	"net/http"
)

func logHandler(w http.ResponseWriter, r *http.Request) {

	if r.Method == http.MethodDelete {
		log.Printf("Blocked method: %s | Path: %s\n", r.Method, r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	log.Printf("Method: %s | Path: %s\n", r.Method, r.URL.Path)
	w.WriteHeader(http.StatusOK)
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/A", logHandler)
	mux.HandleFunc("/A/B", logHandler)
	mux.HandleFunc("/", logHandler)

	log.Println("Server started on port 3000")

	err := http.ListenAndServe(":3000", mux)
	if err != nil {
		log.Fatal(err)
	}
}
