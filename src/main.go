package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func postTrain(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "postTrain called!"}`))
}

func postPredict(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "postPredict called!"}`))
}

func getReport(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "getReport called!"}`))
}

func main() {
	r := mux.NewRouter() 
	api := r.PathPrefix("/api/v1").Subrouter()
	api.HandleFunc("/train", postTrain).Methods(http.MethodPost)
	api.HandleFunc("/predict", postPredict).Methods(http.MethodPost)
	api.HandleFunc("/report", getReport).Methods(http.MethodGet)
	log.Fatal(http.ListenAndServe(":80", r))
}
