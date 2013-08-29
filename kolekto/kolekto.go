package kolekto

import (
    "strings"
    "labix.org/v2/mgo"
    "labix.org/v2/mgo/bson"
)

type dbentry struct {
    Word string `bson:"word"`
    WordLowercase string `bson:"word_lc"`
    Translations []string `bson:"translations"`
}

type DictionaryEntry struct {
    Word string "json:`word`"
    Translations []string "json:`translations`"
}

type Dictionary struct {
    Name string
    Entries []*DictionaryEntry
}

func New(address string) (*Kolekto, error) {
    session, err := mgo.Dial(address)
    if err != nil {
        return nil, err
    }

    kolekto := &Kolekto {
        session: session,
        dbName: "dictionaries",
    }
    return kolekto, nil
}
func (this *Kolekto) getCollection(colName string) *mgo.Collection {
    return this.session.DB(this.dbName).C(colName)
}

type Kolekto struct {
    session *mgo.Session
    dbName string
}

func (this *Kolekto) Dictionaries() ([]string, error) {
    names, err := this.session.DB(this.dbName).CollectionNames()
    if err != nil {
        return []string{}, err
    }
    dicts := make([]string, 0, len(names) - 1)
    for _, name := range names {
        // Filter out unwanted collections (i.e. system.indexes)
        if len(name) == 5 && strings.Contains(name, "_") {
            dicts = append(dicts, name)
        }
    }
    return dicts, nil
}

func (this *Kolekto) Find(dictName, query string, limit int) ([]*DictionaryEntry, error) {
    c := this.getCollection(dictName)
    entries := make([]*DictionaryEntry, 0)
    re := bson.RegEx{Pattern: strings.ToLower(query)}
    err := c.Find(bson.M{"word_lc": re}).Limit(limit).All(&entries)
    if err != nil {
        return nil, err
    }
    return entries, nil
}
