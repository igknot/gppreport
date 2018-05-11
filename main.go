package main

import (
	"database/sql"

	"fmt"
	"github.com/igknot/gppreport/database"
	"github.com/joho/sqltocsv"

	_ "github.com/mattn/go-oci8"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/smtp"
	"os"
	"path/filepath"
	"strings"
	"time"
	"github.com/jasonlvhit/gocron"
)

func generate(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "GGP PASA reports are being regenerated")
	log.Println("Endpoint Hit: generate")
	go genAndMail()
}

func handleRequests() {
 log.Println("Listening")
	//http.HandleFunc("/generate", generate)
	http.Handle("/reports/", http.StripPrefix("/reports/", http.FileServer(http.Dir("reports"))))
	log.Fatal(http.ListenAndServe(":8081", nil))
}

func main() {
	go handleRequests()
	//gocron.Every(1).Friday().At("05:00").Do(genAndMail)
	log.Println("Things go further")
	gocron.Every(2).Minutes().Do(genAndMail)

	<-gocron.Start()

	//handleRequests()

	//genAndMail()
}

func genAndMail() {

	db := database.NewConnection()
	defer db.Close()

	createReports(db)

	sendReports()

}
func sendReports() {
	mailfrom := os.Getenv("MAILFROM")
	if mailfrom == "" {
		panic("MAILFROM not set")
	}
	mailto := os.Getenv("MAILTO")
	if mailto == "" {
		panic("MAILTO environment variable not set")
	}
	server := os.Getenv("MAILSERVER")
	if server == "" {
		panic("MAILSERVER environment variable not set")
	}

	c, err := smtp.Dial(server)
	if err != nil {
		panic(err)
	}

	c.Mail(mailfrom)
	c.Rcpt(mailto)

	data, err := c.Data()
	if err != nil {
		panic(err)
	}
	defer data.Close()

	boundary := "d835e53b6b161cff115c5aaced91d1407779efa3844811da6eb831b6789b2a9a"
	defaultFormat := "2006-01-02"
	t := time.Now().Format(defaultFormat)

	fmt.Fprintf(data, "Subject: %s %s\n", "GPP Health Indicator reports", t)
	fmt.Fprintf(data, "MIME-Version: 1.0\n")
	fmt.Fprintf(data, "Content-Type: multipart/mixed; boundary=%s\n", boundary)

	fmt.Fprintf(data, "\n--%s\n", boundary)
	fmt.Fprintf(data, "Content-Type: text/plain; charset=utf-8\n\n")
	fmt.Fprintf(data, "This email should contain attachments\n\n")

	files, err := ioutil.ReadDir(os.Getenv("REPORT_DIR"))
	if err != nil {
		panic("Unable to read directory " + err.Error())
	}

	for _, file := range files {
		log.Println("Adding " + file.Name())
		addAttachment(data, os.Getenv("REPORT_DIR")+"/"+file.Name(), boundary)
	}

	fmt.Fprintf(data, "--%s--\n", boundary)
	log.Println("Mail sent to " + mailto)
}

func removeOldReports() {
	rdir := os.Getenv("REPORT_DIR")
	files, err := ioutil.ReadDir(rdir)
	if err != nil {
		panic("Unable to read directory " + err.Error())
	}

	for _, f := range files {
		log.Println("Deleting" + rdir + f.Name())
		if err := os.Remove(rdir + "/" + f.Name()); err != nil {
			panic(err)
		}
	}
}

func createReports(db *sql.DB) {

	env := os.Getenv("ENVIRONMENT")
	query_dir := os.Getenv("QUERY_DIR")

	files, err := ioutil.ReadDir(query_dir)
	if err != nil {
		panic("Unable to read directory " + err.Error())
	}
	removeOldReports()

	for _, f := range files {
		log.Println("Start: " + f.Name())
		reportName := strings.TrimSuffix(f.Name(), ".sql")

		queryBytes, err := ioutil.ReadFile(query_dir + "/" + f.Name())
		if err != nil {
			panic("Unable to read file  " + f.Name() + err.Error())
		}
		baseQuery := string(queryBytes)
		defaultFormat := "2006-01-02"
		weekDay := int(time.Now().Weekday())
		lastFriday := time.Now().AddDate(0, 0, -(weekDay + 2)).Format(defaultFormat)
		previousFriday := time.Now().AddDate(0, 0, -(weekDay + 9)).Format(defaultFormat)

		query := baseQuery + "and  p_time_stamp >= ('" + previousFriday + "') and p_time_stamp < ('" + lastFriday + "')"
		//query := baseQuery //+ " \n FETCH FIRST 10 rows only "
		//fmt.Println(query)

		rows, err := db.Query(query)

		defer rows.Close()

		if err != nil {
			log.Println("Unable to execute query   " + f.Name())
			panic(err)
		}

		errb := sqltocsv.WriteFile(os.Getenv("REPORT_DIR")+"/"+reportName+"_"+env+"_"+previousFriday+"_to_"+lastFriday+".csv", rows)
		if errb != nil {
			panic(err)
		}
		log.Println("End: " + f.Name())
	}
}

func addAttachment(w io.Writer, file, boundary string) {
	fmt.Fprintf(w, "\n--%s\n", boundary)
	contents, err := os.Open(file)
	if err != nil {
		fmt.Fprintf(w, "Content-Type: text/csv; charset=utf-8\n")
		fmt.Fprintf(w, "could not open file: %v\n", err)
	} else {
		defer contents.Close()
		fmt.Fprintf(w, "Content-Type: text/csv; charset=utf-8\n")
		fmt.Fprintf(w, "Content-Disposition: attachment; filename=\"%s\"\n\n", filepath.Base(file))
		io.Copy(w, contents)

	}
}
