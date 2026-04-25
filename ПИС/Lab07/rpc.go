package main

import (
	"errors"
	"fmt"
)

type RPCRequest struct {
	JSONRPC   string
	Method    string
	Params    interface{}
	HasParams bool
	ID        interface{}
	HasID     bool
}

type RPCResponse struct {
	JSONRPC string      `json:"jsonrpc"`
	Result  interface{} `json:"result,omitempty"`
	Error   *RPCError   `json:"error,omitempty"`
	ID      interface{} `json:"id"`
}

type RPCError struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

var precision = 2
var ErrDivByZero = errors.New("division by zero")

const (
	ErrCodeParseError     = -32700
	ErrCodeInvalidRequest = -32600
	ErrCodeMethodNotFound = -32601
	ErrCodeInvalidParams  = -32602
	ErrCodeInternalError  = -32603
)

func newRPCError(code int, message string, data interface{}) *RPCError {
	return &RPCError{
		Code:    code,
		Message: message,
		Data:    data,
	}
}

func newErrorResponse(id interface{}, code int, message string, data interface{}) *RPCResponse {
	return &RPCResponse{
		JSONRPC: "2.0",
		Error:   newRPCError(code, message, data),
		ID:      id,
	}
}

func formatResult(val float64) string {
	return fmt.Sprintf("%.*f", precision, val)
}

func sum(x, y float64) string {
	return formatResult(x + y)
}

func sub(x, y float64) string {
	return formatResult(x - y)
}

func mul(x, y float64) string {
	return formatResult(x * y)
}

func div(x, y float64) (string, error) {
	if y == 0 {
		return "", ErrDivByZero
	}
	return formatResult(x / y), nil
}
