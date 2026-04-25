package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {

	initDB()

	r := mux.NewRouter()

	r.HandleFunc("/Celebrities/All", getAllHandler).Methods(http.MethodGet)
	r.HandleFunc("/Celebrities/{id}", getByIDHandler).Methods(http.MethodGet)
	r.HandleFunc("/Celebrities", addCelebrityHandler).Methods(http.MethodPost)
	r.HandleFunc("/Celebrities/{id}", updateCelebrityHandler).Methods(http.MethodPut)
	r.HandleFunc("/Celebrities/{id}", deleteCelebrityHandler).Methods(http.MethodDelete)

	log.Println("Server started on port 3000")

	err := http.ListenAndServe(":3000", r)
	if err != nil {
		log.Fatal(err)
	}

}
