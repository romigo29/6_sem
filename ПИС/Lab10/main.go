package main

import (
	"log"
	"net/http"

	"github.com/graphql-go/handler"
)

func main() {

	initDB()

	h := handler.New(&handler.Config{
		Schema:   &Schema,
		Pretty:   true,
		GraphiQL: true, // Включает UI для тестирования в браузере
	})

	// GraphQL использует только один маршрут для всех операций
	http.Handle("/graphql", h)

	log.Println("GraphQL server started on port 3000")

	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatal(err)
	}

}
