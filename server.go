package main

import (
    "log"
    "time"
    "net/http"
    "encoding/json"
    "github.com/bmizerany/pat"
    "./kolekto"
)

func jsonResponse(res http.ResponseWriter, i interface{}) {
    res.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(res).Encode(i)
    if err != nil {
        log.Println(err)
    }
}

func main() {
    k, err := kolekto.New()
    if err != nil {
        log.Fatalln(err)
    }

    p := pat.New()

    p.Get("/api/dictionaries", http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
        dicts, err := k.Dictionaries()
        if err != nil {
            log.Println(err)
        }
        jsonResponse(res, dicts)
    }))

    p.Get("/api/dictionaries/:dict/:query", http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
        dict := req.URL.Query().Get(":dict")
        query := req.URL.Query().Get(":query")
        t0 := time.Now()
        entries, _ := k.Find(dict, query, 90)
        t1 := time.Now()
        log.Printf("The query (%s) took %v\n", query, t1.Sub(t0))
        jsonResponse(res, entries)
    }))

    http.Handle("/", http.FileServer(http.Dir("./web/")))
    http.Handle("/api/", p)
    err = http.ListenAndServe(":8082", nil)
    if err != nil {
        log.Fatalln("ListenAndServe: ", err)
    }
}

