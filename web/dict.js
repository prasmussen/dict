Dict = Ember.Application.create();

Dict.range = function(start, stop) {
    var numbers = [];
    for (var i = start; i < stop; i++) {
        numbers.push(i);
    }
    return numbers;
};

Dict.Backend = Ember.Object.create({
    baseUrl: "http://" + document.location.host + "/api",

    find: function(lang, query, target, action) {
        var path = "/dictionaries/" + lang + "/" + query; 
        this.GET(path, target, action) 
    },

    GET: function(path, target, action) {
        this._ajax("GET", path, target, action);
    },

    _ajax: function(type, path, target, action, data) {
        var self = this;
        var json = data ? JSON.stringify(data) : null;
        $.ajax({
            type: type,
            url: self.baseUrl + path,
            data: json,
            contentType: "application/json",
            processData: false,
            success: function(data) {
                target[action].call(target, data);
            }
        });
    },
})

Dict.HashController = Ember.Object.create({
    triggers: {},

    init: function() {
        var self = this;
        $(window).bind("hashchange", function(e) {
            self.onHashchange(this.location.hash.slice(1));
        });
    },

    onHashchange: function(hash) {
        if (!this.triggers.hasOwnProperty(hash)) {
            return;
        }
        this.triggers[hash].forEach(function(trigger) {
            trigger.target[trigger.action].call(trigger.target, hash);
        });
    },

    bind: function(hash, action, target) {
        var hashes = [];
        if (Array.isArray(hash)) {
            hashes = hash;
        } else {
            hashes.push(hash);
        }
        var triggers = this.triggers;
        hashes.forEach(function(hash) {
            if (!triggers.hasOwnProperty(hash)) {
                triggers[hash] = [];
            }
            triggers[hash].push({target: target, action: action})
        });
    },
});

Dict.KeyController = Ember.Object.create({
    triggers: {},

    init: function() {
        var self = this;
        $(document).keydown(function(e) {
            self.onKeydown(e);
        });
    },

    onKeydown: function(e) {
        var keyCode;
        if (e.shiftKey) {
            keyCode = "shift-" + e.keyCode;
        } else if (e.altKey) {
            keyCode = "alt-" + e.keyCode;
        } else {
            keyCode = e.keyCode;
        }
        if (!this.triggers.hasOwnProperty(keyCode)) {
            return;
        }
        var bubble = false;
        this.triggers[keyCode].forEach(function(trigger) {
            trigger.target[trigger.action].call(trigger.target, keyCode);
            if (trigger.bubble) {
                bubble = true;
            }
        });
        if (!bubble) {
            e.preventDefault();
        }
    },

    bind: function(keyCode, action, target, bubble) {
        var bubble = bubble || false;
        var keyCodes = [];
        if (Array.isArray(keyCode)) {
            keyCodes = keyCode;
        } else {
            keyCodes.push(keyCode);
        }
        var triggers = this.triggers;
        keyCodes.forEach(function(keyCode) {
            if (!triggers.hasOwnProperty(keyCode)) {
                triggers[keyCode] = [];
            }
            triggers[keyCode].push({target: target, action: action, bubble: bubble});
        });
    },
});

Dict.Language = Ember.Object.extend({
    name: "",
    
    href: function() {
        return "#" + this.get("name");
    }.property("name"),

    title: function() {
        return this.get("name").toUpperCase().replace("_", "-");
    }.property("name"),

    selected: function() {
        return this === Dict.SelectedLanguageController.get("content");
    }.property("Dict.SelectedLanguageController.content"),
});

Dict.SelectedLanguageController = Ember.Object.create({
    content: null,
});

Dict.LanguageController = Ember.ArrayController.create({
    content: [],
    languages: ["no_uk", "uk_no", "no_no", "uk_uk", "no_de", "de_no", "uk_fr", "fr_uk", "uk_es", "es_uk", "se_uk", "uk_se", "no_me"],

    init: function() {
        var languages = this.get("languages");
        var wrapped = languages.map(function(lang) {
            return Dict.Language.create({name: lang})
        });
        this.set("content", wrapped);
        Dict.SelectedLanguageController.set("content", this.getPath("content.firstObject"))
        Dict.KeyController.bind(Dict.range(112, 124), "hotKey", this); // F1-F12
        Dict.KeyController.bind(9, "selectNext", this); // Tab
        Dict.KeyController.bind("shift-9", "selectPrev", this); // Shift-Tab
        Dict.HashController.bind(languages, "hashChanged", this);
    },

    hotKey: function(keyCode) {
        var index = keyCode - 112;
        this.setSelectedIndex(index);
    },

    hashChanged: function(lang) {
        var index = this.get("languages").indexOf(lang);
        this.setSelectedIndex(index);
    },

    setSelectedIndex: function(index) {
        Dict.SelectedLanguageController.set("content", this.get("content").objectAt(index));
    },

    selectNext: function() {
        this.setSelectedIndex(this.getSelectedIndex(1));
    },

    selectPrev: function() {
        this.setSelectedIndex(this.getSelectedIndex(-1));
    },

    getSelectedIndex: function(offset) {
        var languages = this.get("content");
        var index = languages.indexOf(Dict.SelectedLanguageController.get("content")) + offset;
        if (index >= languages.length) {
            index = 0;
        } else if (index < 0) {
            index = languages.length - 1;
        }
        return index;
    },
});

Dict.CurrentQuery = Ember.Object.create({
    content: "",
    invalidChars: ["/", "\\\\"],

    query: function() {
        var content = this.get("content");
        var query = "";

        if (!content) {
            return null;
        } else if (content[0] == "/") {
            query = content.slice(1);
        } else {
            query = "^" + content;
        }
        return this.clean(query);
    }.property("content"),

    clean: function(query) {
        this.invalidChars.forEach(function(c) {
            var re = new RegExp(c, "g");
            query = query.replace(re, "")
        });
        return query;
    },
});

Dict.QueryInput = Ember.TextField.extend({
    attributeBindings: ["autocomplete"],

    init: function() {
        this._super();
        Dict.KeyController.bind(Dict.range(65, 91), "doFocus", this, true); // [a-z]
        Dict.KeyController.bind(8, "doFocus", this, true); // Backspace
    },

    doFocus: function() {
        this.$().focus();
    },

    didInsertElement: function() {
        this._super();
        this.$().focus();
    },

    keyUp: function(e) {
        if (e.keyCode === 27) { // Escape
            this.$().val("");
        }
        Dict.CurrentQuery.set("content", this.$().val());
    },
});


Dict.Entry = Ember.Object.extend({
    content: null,

    word: function() {
        return this.getPath("content.Word");
    }.property("content"),

    translation: function() {
        return this.getPath("content.Translations").join(", ");
    }.property("content"),
});

Dict.EntryController = Ember.ArrayController.create({
    content: [],
    itemsPerPage: 10,
    pageIndex: 0,

    init: function() {
        this._super();
        Dict.KeyController.bind(38, "decrementPage", this); // UpArrow
        Dict.KeyController.bind(40, "incrementPage", this); // DownArrow
    },

    entries: function() {
        return this.get("content").map(function(item) {
            return Dict.Entry.create({content: item});
        });
    }.property("content").cacheable(),

    pageCount: function() {
        var count = this.get("entries").length;
        return Math.ceil(count / this.get("itemsPerPage"));
    }.property("content.items.@each", "itemsPerPage").cacheable(),

    pages: function() {
        var pageCount = this.get("pageCount");
        var pages = [];
        for (var i = 0; i < pageCount; i++) {
            pages.push({text: (i + 1).toString()});
        }
        return {items: pages};
    }.property("entries").cacheable(),

    needsPagination: function() {
        return this.get("pageCount") > 1;
    }.property("pageCount"),

    paginated: function() {
        var entries = this.get("entries");
        var itemsPerPage = this.get("itemsPerPage");
        var start = this.get("pageIndex") * itemsPerPage;
        var stop = Math.min(start + itemsPerPage, entries.length);
        return entries.slice(start, stop);
    }.property("entries", "pageIndex").cacheable(),

    queryChanged: function() {
        if (Dict.CurrentQuery.get("query") == null) {
            this.set("content", []);
        } else {
            this.load();
        }
    }.observes("Dict.CurrentQuery.query", "Dict.SelectedLanguageController.content"),

    incrementPage: function() {
        var current = this.get("pageIndex");
        var pageCount = this.get("pageCount");
        if (current + 1 < pageCount) {
            this.incrementProperty("pageIndex");
        }
    },

    decrementPage: function() {
        var current = this.get("pageIndex");
        if (current > 0) {
            this.decrementProperty("pageIndex");
        }
    },

    load: function() {
        var query = Dict.CurrentQuery.get("query");
        var lang = Dict.SelectedLanguageController.getPath("content.name");
        if (query && lang) {
            Dict.Backend.find(lang, query, this, "onData");
        }
    },

    onData: function(data) {
        this.set("content", data);
        this.set("pageIndex", 0);
    },
});


