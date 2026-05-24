package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	httpSwagger "github.com/swaggo/http-swagger"

	_ "GO11_01/docs" 
)

// @title Celebrity CRUD API (GO11_01)
// @version 1.0
// @description RESTful API веб-сервер для работы с реляционной БД (CRUD)
// @host localhost:3000
// @BasePath /
func main() {

	initDB()

	r := mux.NewRouter()

	// CRUD Маршруты
	r.HandleFunc("/Celebrities/All", getAllHandler).Methods(http.MethodGet)
	r.HandleFunc("/Celebrities/{id}", getByIDHandler).Methods(http.MethodGet)
	r.HandleFunc("/Celebrities", addCelebrityHandler).Methods(http.MethodPost)
	r.HandleFunc("/Celebrities/{id}", updateCelebrityHandler).Methods(http.MethodPut)
	r.HandleFunc("/Celebrities/{id}", deleteCelebrityHandler).Methods(http.MethodDelete)

	// Маршрут для Swagger UI
	r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	log.Println("Server started on port 3000")
	log.Println("Swagger UI available at: http://localhost:3000/swagger/index.html")

	err := http.ListenAndServe(":3000", r)
	if err != nil {
		log.Fatal(err)
	}
}
