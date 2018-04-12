package database

import (
	"database/sql"
	_ "github.com/mattn/go-oci8"
	"log"
)

func NewConnection() *sql.DB {
	connectionString := OracleUser() + "/" + OraclePassword() + "@" + OracleHost() + ":" + OraclePort() + "/" + OracleService()
	db, err := sql.Open("oci8", connectionString)
	if err != nil {
		log.Println("Unable to create database connection")
	} else {
		log.Println("Connection created")
	}
	return db
}
