package database

import (
	"database/sql"
	_ "github.com/mattn/go-oci8"
	"log"
)

func NewConnection() *sql.DB {
	user, _ := OracleUser()
	password, _ := OraclePassword()
	host, _ := OracleHost()
	port, _ := OraclePort()
	service, _ := OracleService()
	connectionString := user + "/" + password + "@" + host + ":" + port + "/" + service
	db, err := sql.Open("oci8", connectionString)
	if err != nil {
		panic("Unable to create database connection")
	} else {
		log.Println("Connection created")
	}
	//if err = db.Ping(); err != nil {
	//	panic("Error connecting to the database: %s\n" + err.Error())
	//
	//}
	return db
}
