package main

import (

	"fmt"
	"github.com/joho/sqltocsv"
	_ "github.com/mattn/go-oci8"
	"io/ioutil"

	"github.com/igknot/gppreport/database"
)

func main() {
	db := database.NewConnection()



	defer db.Close()


	queryBytes, err := ioutil.ReadFile("collections_v1_0.sql")
	query := string(queryBytes)

	fmt.Print("Query:", query)

	rows, err := db.Query(query)

	errb := sqltocsv.WriteFile("important_user_report.csv", rows)
	if errb != nil {
		panic(err)
	}

	defer rows.Close()

}
