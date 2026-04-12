package main

import (
	"database/sql"
	"log"

	_ "github.com/denisenkom/go-mssqldb"
)

var db *sql.DB

func initDB() {
	var err error

	connString := "sqlserver://student:fitfit@localhost:1433?database=CelebrityDB&encrypt=disable"

	db, err = sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatal("sql.Open error: ", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatal("DB connection failed: ", err)
	}

	log.Println("Connected to SQL Server")
}
