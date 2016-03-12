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
    Cert string
    Privkey string
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
        // Start measuring time
        start := time.Now()

        // Grab query params
        dict := req.URL.Query().Get(":dict")
        query := req.URL.Query().Get(":query")

        // Find matches and return response
        entries, _ := k.Find(dict, query, 90)
        jsonResponse(res, entries)

        // Print out used time
        log.Printf("The query (%s) took %v\n", query, time.Now().Sub(start))
    }))

    http.Handle("/", http.FileServer(http.Dir("./web/")))
    http.Handle("/api/", p)
    httpsRedirector := http.RedirectHandler("https://d.rasm.se", http.StatusMovedPermanently)

    log.Println("Listening on port 80 and 443")
    go http.ListenAndServe(":80", httpsRedirector)
    err = http.ListenAndServeTLS(":443", cfg.Cert, cfg.Privkey, nil)
    if err != nil {
        log.Fatalln("ListenAndServe: ", err)
    }
}
