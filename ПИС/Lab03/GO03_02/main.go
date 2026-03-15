package main

import (
	"GO03_02/P03_02"
	"fmt"
	"log"
	"net/http"
)

var stats P03_02.Statistics

func handlerS(w http.ResponseWriter, r *http.Request) {

	switch r.Method {
	case http.MethodGet:
		stats.PlusGet()
		log.Println("GET /S")
	case http.MethodPost:
		stats.PlusPost()
		log.Println("POST /S")

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func handlerG(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	result := stats.GenStr()

	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, result)
}

func handlerDefault(w http.ResponseWriter, r *http.Request) {

	if r.URL.Path != "/S" && r.URL.Path != "/G" {
		log.Printf("Blocked path: %s | Method: %s\n", r.URL.Path, r.Method)
		http.Error(w, "Path not allowed", http.StatusNotFound)
		return
	}
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/S", handlerS)
	mux.HandleFunc("/G", handlerG)
	mux.HandleFunc("/", handlerDefault)

	log.Println("Server started on port 3000")

	err := http.ListenAndServe(":3000", mux)
	if err != nil {
		log.Fatal(err)
	}
}
