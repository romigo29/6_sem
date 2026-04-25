package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
)

func RPCHandler(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		log.Println("Read error:", err)
		writeResponse(w, newErrorResponse(nil, ErrCodeInvalidRequest, "Invalid Request", "failed to read request body"))
		return
	}

	trimmedBody := bytes.TrimSpace(body)
	if len(trimmedBody) == 0 {
		writeResponse(w, newErrorResponse(nil, ErrCodeParseError, "Parse error", "request body is empty"))
		return
	}

	if trimmedBody[0] == '[' {
		var batch []json.RawMessage
		if err := decodeJSON(trimmedBody, &batch); err != nil {
			writeResponse(w, newErrorResponse(nil, ErrCodeParseError, "Parse error", err.Error()))
			return
		}

		if len(batch) == 0 {
			writeResponse(w, newErrorResponse(nil, ErrCodeInvalidRequest, "Invalid Request", "batch request must not be empty"))
			return
		}

		var responses []RPCResponse
		for _, rawRequest := range batch {
			req, parseErr := parseRPCRequest(rawRequest)
			if parseErr != nil {
				responses = append(responses, *parseErr)
				continue
			}

			resp := handleSingleRequest(req)
			if resp != nil {
				responses = append(responses, *resp)
			}
		}

		if len(responses) == 0 {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		writeResponse(w, responses)
		return
	}

	req, parseErr := parseRPCRequest(trimmedBody)
	if parseErr != nil {
		writeResponse(w, parseErr)
		return
	}

	resp := handleSingleRequest(req)
	if resp != nil {
		writeResponse(w, resp)
	}
}

func handleSingleRequest(req RPCRequest) *RPCResponse {
	log.Printf("Method: %s", req.Method)

	switch req.Method {
	case "sum":
		x, y, err := parseXY(req.Params, req.HasParams)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}
		return &RPCResponse{JSONRPC: "2.0", Result: sum(x, y), ID: req.ID}

	case "sub":
		x, y, err := parseXY(req.Params, req.HasParams)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}
		return &RPCResponse{JSONRPC: "2.0", Result: sub(x, y), ID: req.ID}

	case "mul":
		x, y, err := parseXY(req.Params, req.HasParams)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}
		return &RPCResponse{JSONRPC: "2.0", Result: mul(x, y), ID: req.ID}

	case "div":
		x, y, err := parseXY(req.Params, req.HasParams)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}

		result, err := div(x, y)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}

		return &RPCResponse{JSONRPC: "2.0", Result: result, ID: req.ID}

	case "pre":
		n, err := parsePrecision(req.Params, req.HasParams)
		if err != nil {
			return requestErrorResponse(req, ErrCodeInvalidParams, "Invalid params", err.Error())
		}

		precision = n
		log.Printf("Precision set to %d", precision)

		if !req.HasID {
			return nil
		}

		return &RPCResponse{JSONRPC: "2.0", Result: "ok", ID: req.ID}

	default:
		return requestErrorResponse(req, ErrCodeMethodNotFound, "Method not found", fmt.Sprintf("method %q is not supported", req.Method))
	}
}

func parseRPCRequest(data []byte) (RPCRequest, *RPCResponse) {
	var raw interface{}
	if err := decodeJSON(data, &raw); err != nil {
		return RPCRequest{}, newErrorResponse(nil, ErrCodeParseError, "Parse error", err.Error())
	}

	payload, ok := raw.(map[string]interface{})
	if !ok {
		return RPCRequest{}, newErrorResponse(nil, ErrCodeInvalidRequest, "Invalid Request", "request must be a JSON object")
	}

	req := RPCRequest{}

	if id, exists := payload["id"]; exists {
		if !isValidID(id) {
			return RPCRequest{}, newErrorResponse(nil, ErrCodeInvalidRequest, "Invalid Request", `field "id" must be string, integer or null`)
		}

		req.ID = id
		req.HasID = true
	}

	jsonrpc, ok := payload["jsonrpc"].(string)
	if !ok || strings.TrimSpace(jsonrpc) == "" {
		return RPCRequest{}, newErrorResponse(req.ID, ErrCodeInvalidRequest, "Invalid Request", `required field "jsonrpc" is missing or invalid`)
	}
	if jsonrpc != "2.0" {
		return RPCRequest{}, newErrorResponse(req.ID, ErrCodeInvalidRequest, "Invalid Request", `field "jsonrpc" must be "2.0"`)
	}
	req.JSONRPC = jsonrpc

	method, ok := payload["method"].(string)
	if !ok || strings.TrimSpace(method) == "" {
		return RPCRequest{}, newErrorResponse(req.ID, ErrCodeInvalidRequest, "Invalid Request", `required field "method" is missing or invalid`)
	}
	req.Method = method

	if params, exists := payload["params"]; exists {
		switch params.(type) {
		case []interface{}, map[string]interface{}, nil:
			req.Params = params
			req.HasParams = true
		default:
			return RPCRequest{}, newErrorResponse(req.ID, ErrCodeInvalidParams, "Invalid params", `field "params" must be an object or array`)
		}
	}

	return req, nil
}

func requestErrorResponse(req RPCRequest, code int, message string, data interface{}) *RPCResponse {
	if !req.HasID {
		return nil
	}

	return newErrorResponse(req.ID, code, message, data)
}

func decodeJSON(data []byte, dest interface{}) error {
	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.UseNumber()

	if err := decoder.Decode(dest); err != nil {
		return err
	}

	var extra interface{}
	if err := decoder.Decode(&extra); err != io.EOF {
		return errors.New("request must contain exactly one JSON value")
	}

	return nil
}

func writeResponse(w http.ResponseWriter, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("write response error: %v", err)
	}
}
