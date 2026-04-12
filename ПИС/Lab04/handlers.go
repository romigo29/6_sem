package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"github.com/gorilla/mux"
)

func getAllHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s", r.Method, r.URL.Path)

	data, _ := loadCelebrities()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
	log.Printf("200 OK, returned %d items", len(data))
}

func getByIDHandler(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	log.Printf("GET /Celebrities/%s", params["id"])

	id, _ := strconv.Atoi(params["id"])

	data, _ := loadCelebrities()

	for _, c := range data {
		if c.Id == id {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(c)
			log.Printf("200 OK, id=%d (%s)", id, c.FullName)
			return
		}
	}

	log.Printf("404, id=%d not found", id)
	http.Error(w, "Not found", http.StatusNotFound)
}

func addCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("POST /Celebrities")

	var newC Celebrity
	json.NewDecoder(r.Body).Decode(&newC)

	if newC.Id <= 0 {
		log.Printf("invalid id=%d (must be > 0)", newC.Id)
		http.Error(w, "Invalid ID: must be > 0", http.StatusBadRequest)
		return
	}

	data, _ := loadCelebrities()

	for _, c := range data {
		if c.Id == newC.Id {
			log.Printf("409, duplicate id=%d", newC.Id)
			http.Error(w, "Duplicate ID", http.StatusConflict)
			return
		}
	}

	data = append(data, newC)
	saveCelebrities(data)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(newC)
	log.Printf("201 Created, id=%d (%s)", newC.Id, newC.FullName)
}

func updateCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	log.Printf("PUT /Celebrities/%s", params["id"])

	id, _ := strconv.Atoi(params["id"])

	var updated Celebrity
	json.NewDecoder(r.Body).Decode(&updated)

	updated.Id = id

	data, _ := loadCelebrities()

	for i, c := range data {
		if c.Id == id {
			data[i] = updated
			saveCelebrities(data)
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(updated)
			log.Printf("200 OK, updated id=%d (%s)", id, updated.FullName)
			return
		}
	}

	log.Printf("404, id=%d not found", id)
	http.Error(w, "Not found", http.StatusNotFound)
}

func deleteCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	log.Printf("DELETE /Celebrities/%s", params["id"])

	id, _ := strconv.Atoi(params["id"])

	data, _ := loadCelebrities()

	for i, c := range data {
		if c.Id == id {
			data = append(data[:i], data[i+1:]...)
			saveCelebrities(data)
			w.WriteHeader(http.StatusNoContent)
			log.Printf("204 No Content, deleted id=%d", id)
			return
		}
	}

	log.Printf("404, id=%d not found", id)
	http.Error(w, "Not found", http.StatusNotFound)
}
