package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

func getAllHandler(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities")
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	var list []Celebrity

	for rows.Next() {
		var c Celebrity
		rows.Scan(&c.Id, &c.FullName, &c.Nationality, &c.ReqPhotoPath)
		list = append(list, c)
	}

	json.NewEncoder(w).Encode(list)
}

func getByIDHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	var c Celebrity

	err := db.QueryRow(
		"SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities WHERE Id = @p1",
		id,
	).Scan(&c.Id, &c.FullName, &c.Nationality, &c.ReqPhotoPath)

	if err == sql.ErrNoRows {
		http.Error(w, "Not found", 404)
		return
	}

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	json.NewEncoder(w).Encode(c)
}

func addCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	var c Celebrity
	json.NewDecoder(r.Body).Decode(&c)

	_, err := db.Exec(`
		INSERT INTO Celebrities (Id, FullName, Nationality, ReqPhotoPath)
		VALUES (@p1, @p2, @p3, @p4)
	`, c.Id, c.FullName, c.Nationality, c.ReqPhotoPath)

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(c)
}

func updateCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	var c Celebrity
	json.NewDecoder(r.Body).Decode(&c)

	result, err := db.Exec(`
		UPDATE Celebrities
		SET FullName=@p1, Nationality=@p2, ReqPhotoPath=@p3
		WHERE Id=@p4
	`, c.FullName, c.Nationality, c.ReqPhotoPath, id)

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		http.Error(w, "Not found", 404)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func deleteCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	result, err := db.Exec("DELETE FROM Celebrities WHERE Id=@p1", id)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		http.Error(w, "Not found", 404)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
