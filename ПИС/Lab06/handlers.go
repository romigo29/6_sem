package main

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

func getAllHandler(w http.ResponseWriter, r *http.Request) {
	var celebrities []Celebrity

	if err := db.Find(&celebrities).Error; err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	json.NewEncoder(w).Encode(celebrities)
}

func getByIDHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	var c Celebrity

	if err := db.First(&c, id).Error; err != nil {
		http.Error(w, "Not found", 404)
		return
	}

	json.NewEncoder(w).Encode(c)
}

func addCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	var c Celebrity

	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		http.Error(w, "Invalid JSON", 400)
		return
	}

	if err := db.Create(&c).Error; err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(c)
}

func updateCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	var c Celebrity

	if err := db.First(&c, id).Error; err != nil {
		http.Error(w, "Not found", 404)
		return
	}

	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		http.Error(w, "Invalid JSON", 400)
		return
	}

	c.Id = id

	db.Save(&c)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(c)
}

func deleteCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	result := db.Delete(&Celebrity{}, id)

	if result.RowsAffected == 0 {
		http.Error(w, "Not found", 404)
		return
	}

	w.WriteHeader(http.StatusOK)
}
