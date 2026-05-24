package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

// @Summary Получить всех знаменитостей
// @Description Возвращает список всех записей из базы данных
// @Tags Celebrities
// @Produce json
// @Success 200 {array} Celebrity
// @Failure 500 {string} string "Internal Server Error"
// @Router /Celebrities/All [get]
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

// @Summary Получить знаменитость по ID
// @Description Возвращает конкретную запись по её идентификатору
// @Tags Celebrities
// @Produce json
// @Param id path int true "ID знаменитости"
// @Success 200 {object} Celebrity
// @Failure 404 {string} string "Not found"
// @Failure 500 {string} string "Internal Server Error"
// @Router /Celebrities/{id} [get]
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

// @Summary Добавить новую знаменитость
// @Description Создает новую запись в базе данных
// @Tags Celebrities
// @Accept json
// @Produce json
// @Param celebrity body Celebrity true "Данные знаменитости (Id игнорируется)"
// @Success 201 {object} Celebrity
// @Failure 500 {string} string "Internal Server Error"
// @Router /Celebrities [post]
func addCelebrityHandler(w http.ResponseWriter, r *http.Request) {
	var c Celebrity
	json.NewDecoder(r.Body).Decode(&c)

	err := db.QueryRow(`
    INSERT INTO Celebrities (FullName, Nationality, ReqPhotoPath)
    OUTPUT INSERTED.Id
    VALUES (@p1, @p2, @p3)
`, c.FullName, c.Nationality, c.ReqPhotoPath).Scan(&c.Id)

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(c)
}

// @Summary Обновить данные знаменитости
// @Description Полностью обновляет существующую запись по ID
// @Tags Celebrities
// @Accept json
// @Produce json
// @Param id path int true "ID знаменитости"
// @Param celebrity body Celebrity true "Новые данные"
// @Success 200 {object} Celebrity
// @Failure 404 {string} string "Not found"
// @Failure 500 {string} string "Internal Server Error"
// @Router /Celebrities/{id} [put]
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

	// Для наглядности возвращаем обновленный ID в структуре
	c.Id = id
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(c)
}

// @Summary Удалить знаменитость
// @Description Удаляет запись из базы данных по ID
// @Tags Celebrities
// @Param id path int true "ID знаменитости"
// @Success 200 {string} string "OK"
// @Failure 404 {string} string "Not found"
// @Failure 500 {string} string "Internal Server Error"
// @Router /Celebrities/{id} [delete]
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

	w.WriteHeader(http.StatusOK)
}