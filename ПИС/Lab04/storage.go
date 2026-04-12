package main

import (
	"encoding/json"
	"os"
	"sync"
)

const fileName = "Celebrities.json"

var mu sync.Mutex

func loadCelebrities() ([]Celebrity, error) {

	mu.Lock()
	defer mu.Unlock()

	file, err := os.ReadFile(fileName)
	if err != nil {
		return nil, err
	}

	var celebrities []Celebrity
	err = json.Unmarshal(file, &celebrities)
	return celebrities, err
}

func saveCelebrities(data []Celebrity) error {

	mu.Lock()
	defer mu.Unlock()

	file, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(fileName, file, 0644)
}
