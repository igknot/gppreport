package main

import (
	"database/sql"
	"fmt"
	"github.com/joho/sqltocsv"
	_ "github.com/mattn/go-oci8"
	"io/ioutil"
	"net/http"
	"github.com/igknot/gppreport/database"
)

/*
TO DO
Only to be run at spefic times
Date validation
password in clear -- wallet or something else




*/
func main() {
	db := database.NewConnection()



	defer db.Close()



	queryBytes, _:= ioutil.ReadFile("collections_v1_0.sql")
	baseQuery := string(queryBytes)



	http.HandleFunc("/collections", func(w http.ResponseWriter, r *http.Request) {
		startDate := r.URL.Query().Get("start")
		endDate := r.URL.Query().Get("end")

		query := baseQuery + "\n and  minf.p_time_stamp > ('" + startDate + "')  and  minf.p_time_stamp < ('" + endDate + "')\n FETCH FIRST 10 rows only "
		fmt.Println(query)

		rows, err1 := db.Query(query)
		fmt.Println("Error ", err1)
		w.Header().Set("Content-type", "text/csv")
		w.Header().Set("Content-Disposition", "attachment; filename=\"collections.csv\"")

		sqltocsv.Write(w, rows)
	})
	http.ListenAndServe(":8081", nil)

}
