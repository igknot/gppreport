package database

import (
	"os"
)

func OracleUser() string {
	return os.Getenv("ORACLE_USER")
}

func OraclePort() string {
	return os.Getenv("ORACLE_PORT")
}

func OraclePassword() string {
	return os.Getenv("ORACLE_PASSWORD")
}

func OracleHost() string {
	return os.Getenv("ORACLE_HOST")
}

func OracleService() string {
	return os.Getenv("ORACLE_SERVICE")
}
