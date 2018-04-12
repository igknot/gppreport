package main

import (
	"fmt"
	"strings"
	"github.com/go-mail/mail"
)


func main() {

	fmt.Println("before sending mail")

	m := mail.NewMessage()
	m.SetHeader("From", "thesender@imaginarybank.co.za")
	m.SetHeader("To", "reciever@gmail.com", "secondreciever@imaginarybank.co.za")
	m.SetAddressHeader("Cc", "dan@example.com", "Dan")
	m.SetHeader("Subject", "Hello!")
	m.SetBody("text/html", "Hello <b>Bob</b> and <i>Cora</i>!")
	m.Attach("reports/Mandate_Inititation_V0_2.csv")
	m.Attach("reports/collections_v1_0_with_pmid.csv")


	//d := mail.NewDialer("mx1.standardbank.co.za", 25   , "a149651", "6yhnMJU&")
	d := mail.NewDialer("smtp.mailtrap.io", 25   , "27cd62989909e2", "f9ab0fcc46104b")

	d.StartTLSPolicy = mail.MandatoryStartTLS

	// Send the email to Bob, Cora and Dan.
	if err := d.DialAndSend(m); err != nil {
		fmt.Println("This is the Error:" + err.Error())
	}

}
