package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
)

func parseXY(params interface{}, hasParams bool) (float64, float64, error) {
	if !hasParams || params == nil {
		return 0, 0, errors.New("params are required")
	}

	switch p := params.(type) {
	case []interface{}:
		if len(p) < 2 {
			return 0, 0, errors.New("params array must contain x and y")
		}

		x, err := numberToFloat64(p[0], "x")
		if err != nil {
			return 0, 0, err
		}

		y, err := numberToFloat64(p[1], "y")
		if err != nil {
			return 0, 0, err
		}

		return x, y, nil

	case map[string]interface{}:
		rawX, ok := p["x"]
		if !ok {
			return 0, 0, errors.New(`required parameter "x" is missing`)
		}

		rawY, ok := p["y"]
		if !ok {
			return 0, 0, errors.New(`required parameter "y" is missing`)
		}

		x, err := numberToFloat64(rawX, "x")
		if err != nil {
			return 0, 0, err
		}

		y, err := numberToFloat64(rawY, "y")
		if err != nil {
			return 0, 0, err
		}

		return x, y, nil
	}

	return 0, 0, errors.New("params must be an object or array")
}

func parsePrecision(params interface{}, hasParams bool) (int, error) {
	if !hasParams || params == nil {
		return 0, errors.New("params are required")
	}

	m, ok := params.(map[string]interface{})
	if !ok {
		return 0, errors.New(`params for method "pre" must be an object`)
	}

	rawN, ok := m["N"]
	if !ok {
		return 0, errors.New(`required parameter "N" is missing`)
	}

	n, err := numberToInt(rawN, "N")
	if err != nil {
		return 0, err
	}

	if n < 0 || n > 15 {
		return 0, errors.New(`parameter "N" must be between 0 and 15`)
	}

	return n, nil
}

func numberToFloat64(value interface{}, field string) (float64, error) {
	switch v := value.(type) {
	case json.Number:
		num, err := v.Float64()
		if err != nil {
			return 0, fmt.Errorf(`parameter "%s" must be a number`, field)
		}
		return num, nil
	case float64:
		return v, nil
	}

	return 0, fmt.Errorf(`parameter "%s" must be a number`, field)
}

func numberToInt(value interface{}, field string) (int, error) {
	switch v := value.(type) {
	case json.Number:
		text := v.String()
		if strings.ContainsAny(text, ".eE") {
			return 0, fmt.Errorf(`parameter "%s" must be an integer`, field)
		}

		var result int
		if _, err := fmt.Sscanf(text, "%d", &result); err != nil {
			return 0, fmt.Errorf(`parameter "%s" must be an integer`, field)
		}
		return result, nil
	case float64:
		if v != float64(int(v)) {
			return 0, fmt.Errorf(`parameter "%s" must be an integer`, field)
		}
		return int(v), nil
	}

	return 0, fmt.Errorf(`parameter "%s" must be an integer`, field)
}

func isValidID(id interface{}) bool {
	switch v := id.(type) {
	case nil, string:
		return true
	case json.Number:
		return !strings.ContainsAny(v.String(), ".eE")
	case float64:
		return v == float64(int(v))
	default:
		return false
	}
}
