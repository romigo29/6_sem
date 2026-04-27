package main

import (
	"log"
	"net/http"
	"os"

	"golang.org/x/net/webdav"
)

const (
	addr     = ":9090"
	rootDir  = "./webdav-data"
	username = "user1"
	password = "12345"
)

func main() {
	err := os.MkdirAll(rootDir, 0755)
	if err != nil {
		log.Fatal(err)
	}

	handler := &webdav.Handler{
		Prefix:     "/",
		FileSystem: webdav.Dir(rootDir),
		LockSystem: webdav.NewMemLS(),
		Logger: func(r *http.Request, err error) {
			if err != nil {
				log.Printf("%s %s -> ERROR: %v", r.Method, r.URL.Path, err)
				return
			}
			log.Printf("%s %s", r.Method, r.URL.Path)
		},
	}

	http.HandleFunc("/", basicAuth(handler))

	log.Printf("GO09_01s WebDAV server started on http://localhost%s/", addr)
	log.Printf("Root directory: %s", rootDir)

	err = http.ListenAndServe(addr, nil)
	if err != nil {
		log.Fatal(err)
	}
}

func basicAuth(next http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, pass, ok := r.BasicAuth()

		if !ok || user != username || pass != password {
			w.Header().Set("WWW-Authenticate", `Basic realm="GO09_01s WebDAV"`)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	}
}
