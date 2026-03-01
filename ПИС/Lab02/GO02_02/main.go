package main

import (
	"GO02_02/go02_02lib"
	"fmt"
	"net/http"
)

const A01 = 3

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>")
	fmt.Fprintf(w, "<h2>GO02_01 Web Server</h2>")
	fmt.Fprintf(w, "A01 = %d<br>", A01)
	fmt.Fprintf(w, "A02 = %t<br>", A02)
	fmt.Fprintf(w, "A03 = %s<br>", go02_02lib.A03)
	fmt.Fprintf(w, "</body></html>")
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server started at http://localhost:4000")
	http.ListenAndServe(":4000", nil)
}
