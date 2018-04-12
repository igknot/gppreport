package main

import (
	"database/sql"

	"github.com/igknot/gppreport/database"
	"github.com/joho/sqltocsv"
	_ "github.com/mattn/go-oci8"
	"io/ioutil"
	"log"
	"strings"
	"os"
)

func main() {
	db := database.NewConnection()
	defer db.Close()

	createReports(db)

	sendReports()

}
func sendReports() {

}
func createReports(db *sql.DB) {

	files, err := ioutil.ReadDir(os.Getenv("QUERY_DIR"))
	if err != nil {
		log.Println("Unable to read directory " + err.Error())
	}
	for _, f := range files {
		log.Println(f.Name())
		reportName := strings.TrimSuffix(f.Name(), ".sql")

		queryBytes, err := ioutil.ReadFile("queries/" + f.Name())
		if err != nil {
			log.Println("Unable to read file  " + f.Name() + err.Error())
		}
		baseQuery := string(queryBytes)

		query := baseQuery //+ " \n FETCH FIRST 10 rows only "
		//fmt.Println(query)

		rows, err := db.Query(query)

		defer rows.Close()

		if err != nil {
			log.Println("Unable to execute query   " + f.Name() + err.Error())
		}

		errb := sqltocsv.WriteFile(os.Getenv("REPORT_DIR") +"/"+reportName+".csv", rows)
		if errb != nil {
			panic(err)
		}

	}
}
