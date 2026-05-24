package main

import (
	"log"

	"gorm.io/driver/sqlserver"
	"gorm.io/gorm"
)

var db *gorm.DB

func initDB() {
	var err error

	connString := "sqlserver://student:fitfit@localhost:1433?database=CelebrityDB&encrypt=disable"

	db, err = gorm.Open(sqlserver.Open(connString), &gorm.Config{})
	if err != nil {
		log.Fatal("DB connection failed: ", err)
	}

	err = db.AutoMigrate(&Celebrity{})

	log.Println("Connected to SQL Server")
}
