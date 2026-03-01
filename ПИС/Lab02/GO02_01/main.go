package main

import (
	"GO02_01/go02_01lib"
	"fmt"
	"net/http"
)

const C01 = 3.14

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>")
	fmt.Fprintf(w, "<h2>GO02_01 Web Server</h2>")
	fmt.Fprintf(w, "C01 = %e<br>", C01)
	fmt.Fprintf(w, "C02 = %e<br>", C02)
	fmt.Fprintf(w, "C03 = %e<br>", go02_01lib.C03)
	fmt.Fprintf(w, "</body></html>")
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server started at http://localhost:3000")
	http.ListenAndServe(":3000", nil)
}
