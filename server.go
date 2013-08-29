package main

import (
    "os"
    "log"
    "time"
    "net/http"
    "encoding/json"
    "github.com/bmizerany/pat"
    "./kolekto"
)

type Config struct {
    Listen string
    Mongodb string
}

func jsonResponse(res http.ResponseWriter, i interface{}) {
    res.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(res).Encode(i)
    if err != nil {
        log.Println(err)
    }
}

func parseConfig(fname string) (*Config, error) {
    f, err := os.Open(fname)
    if err != nil {
        return nil, err
    }
    defer f.Close()

    var cfg *Config
    if err := json.NewDecoder(f).Decode(&cfg); err != nil {
        return nil, err
    }

    return cfg, nil
}

func main() {
    cfg, err := parseConfig("config.json")
    if err != nil {
        log.Fatalln(err)
    }

    log.Printf("Connecting to mongodb: %s\n", cfg.Mongodb)
    k, err := kolekto.New(cfg.Mongodb)
    if err != nil {
        log.Fatalln(err)
    }

    log.Println("Connected")

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

    log.Printf("Listening on %s\n", cfg.Listen)
    err = http.ListenAndServe(cfg.Listen, nil)
    if err != nil {
        log.Fatalln("ListenAndServe: ", err)
    }
}

