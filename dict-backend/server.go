package main

import (
    "os"
    "log"
    "time"
    "net/http"
    "encoding/json"
    "github.com/bmizerany/pat"
)


func jsonResponse(res http.ResponseWriter, i interface{}) {
    res.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(res).Encode(i)
    if err != nil {
        log.Println(err)
    }
}

func main() {
    staticPath := os.Getenv("STATIC_PATH")
    if staticPath == "" {
        log.Fatalln("Missing STATIC_PATH environment variable")
    }

    dbUrl := os.Getenv("DB_URL")
    if dbUrl == "" {
        log.Fatalln("Missing DB_URL environment variable")
    }

    listenAddr := os.Getenv("LISTEN_ADDR")
    if listenAddr == "" {
        listenAddr = ":80"
    }

    log.Printf("Connecting to mongodb: %s\n", dbUrl)
    mongoClient, err := NewMongoClient(dbUrl)
    if err != nil {
        log.Fatalln(err)
    }

    log.Println("Connected")

    p := pat.New()

    p.Get("/api/dictionaries", http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
        dicts, err := mongoClient.Dictionaries()
        if err != nil {
            log.Println(err)
        }
        jsonResponse(res, dicts)
    }))

    p.Get("/api/dictionaries/:dict/:query", http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
        // Start measuring time
        start := time.Now()

        // Grab query params
        dict := req.URL.Query().Get(":dict")
        query := req.URL.Query().Get(":query")

        // Find matches and return response
        entries, _ := mongoClient.Find(dict, query, 90)
        jsonResponse(res, entries)

        // Print out used time
        log.Printf("The query (%s) took %v\n", query, time.Now().Sub(start))
    }))

    http.Handle("/", http.FileServer(http.Dir(staticPath)))
    http.Handle("/api/", p)


    log.Println("Listening on ", listenAddr)
    err = http.ListenAndServe(listenAddr, nil)
    if err != nil {
        log.Fatalln("ListenAndServe: ", err)
    }
}
