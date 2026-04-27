package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

const (
	//baseURL  = "http://localhost:8080"
	baseURL  = "http://localhost:9090"
	username = "user1"
	password = "12345"
)

func main() {
	log.Println("GO09_01c WebDAV client started")

	check("MKCOL", "/go-test", "", nil)
	check("PUT", "/go-test/hello.txt", "", []byte("Hello from GO09_01c WebDAV client\n"))
	check("GET", "/go-test/hello.txt", "", nil)
	check("COPY", "/go-test/hello.txt", "/go-test/hello-copy.txt", nil)
	check("MOVE", "/go-test/hello-copy.txt", "/go-test/hello-moved.txt", nil)
	//check("DELETE", "/go-test/hello.txt", "", nil)
	//check("DELETE", "/go-test/hello-moved.txt", "", nil)
	//check("DELETE", "/go-test", "", nil)

	log.Println("GO09_01c WebDAV client finished")
}

func check(method, path, destination string, body []byte) {
	fmt.Println(strings.Repeat("-", 60))
	fmt.Printf("%s %s\n", method, path)

	statusCode, responseBody, err := sendWebDAVRequest(method, path, destination, body)
	if err != nil {
		log.Printf("ERROR: %v\n", err)
		return
	}

	fmt.Printf("Status: %d %s\n", statusCode, http.StatusText(statusCode))

	if len(responseBody) > 0 {
		fmt.Println("Response body:")
		fmt.Println(string(responseBody))
	}
}

func sendWebDAVRequest(method, path, destination string, body []byte) (int, []byte, error) {
	url := baseURL + path

	var reader io.Reader
	if body != nil {
		reader = bytes.NewReader(body)
	}

	req, err := http.NewRequest(method, url, reader)
	if err != nil {
		return 0, nil, err
	}

	req.SetBasicAuth(username, password)

	if body != nil {
		req.Header.Set("Content-Type", "text/plain; charset=utf-8")
	}

	if destination != "" {
		req.Header.Set("Destination", baseURL+destination)
		req.Header.Set("Overwrite", "T")
	}

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		return 0, nil, err
	}
	defer resp.Body.Close()

	responseBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return resp.StatusCode, nil, err
	}

	if resp.StatusCode >= 400 {
		return resp.StatusCode, responseBody, fmt.Errorf("server returned error status %d", resp.StatusCode)
	}

	if method == "GET" {
		err = os.WriteFile("downloaded_hello.txt", responseBody, 0644)
		if err != nil {
			return resp.StatusCode, responseBody, err
		}
		fmt.Println("File saved as downloaded_hello.txt")
	}

	return resp.StatusCode, responseBody, nil
}
