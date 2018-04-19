package database

import (
	"os"
)

func OracleUser() (user string, err error) {
	user = os.Getenv("ORACLE_USER")
	err = nil
	if user == "" {

		panic("ORACLE_USER Environment variable not set   " )
	}
	return
}

func OraclePort() (port string , err error ) {
	port =  os.Getenv("ORACLE_PORT")
	err = nil
	if port == "" {
		panic("ORACLE_PORT Environment variable not set   " )
	}
	return
}

func OraclePassword() (password string, err error) {
	password =  os.Getenv("ORACLE_PASSWORD")
	err = nil
	if password == "" {
		panic("ORACLE_PASSWORD Environment variable not set   " )

	}
	return
}


func OracleHost() (password string, err error) {
	password =  os.Getenv("ORACLE_HOST")
	err = nil
	if password == "" {
		panic("ORACLE_HOST Environment variable not set   " )
	}
	return
}


func OracleService() (password string, err error) {
	password =  os.Getenv("ORACLE_SERVICE")
	err = nil
	if password == "" {
		panic("ORACLE_SERVICE Environment variable not set   " )
	}
	return
}

