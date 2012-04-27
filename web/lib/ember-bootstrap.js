Bootstrap = Ember.Namespace.create();

Bootstrap.Pagination = Ember.View.extend({
    tagName: "div",
    classNames: ["pagination"],
    template: Ember.Handlebars.compile(
        '<ul>' +
          '<li {{bindAttr class="firstSelected:disabled"}}><a href="#" {{action "prev"}}>&larr;</a></li>' +
            '{{#each content.items}}' + 
              '{{view Bootstrap.ListItem contentBinding="this" classBinding="active"}}' +
            '{{/each}}' +
          '<li {{bindAttr class="lastSelected:disabled"}}><a href="#" {{action "next"}}>&rarr;</a></li>' +
        '</ul>'
    ),

    firstSelected: function() {
        return this.isSelected("firstObject");
    }.property("selectedItem", "content.items").cacheable(),

    lastSelected: function() {
        return this.isSelected("lastObject");
    }.property("selectedItem", "content.items").cacheable(),

    isSelected: function(selector) {
        var item = this.getPath("content.items." + selector);
        var selected = this.get("selectedItem");
        if (!selected) {
            return false;
        }
        return selected === item;
    },

    contentChanged: function() {
        if (!this.getPath("content.items")) {
            return;
        }
        this.set("selectedItem", this.getPath("content.items.firstObject"));
    }.observes("content.items.@each"),

    index: function(key, value) {
        if (arguments.length === 1) {
            return this.getSelectedIndex();
        } else {
            return this.setSelectedIndex(value)
        }
    }.property("content.items", "selectedItem").cacheable(),

    getSelectedIndex: function() {
        var items = this.getPath("content.items");
        var selected = this.getPath("selectedItem");
        if (!selected) {
            return -1;
        }
        var index = -1;
        items.forEach(function(item, i) {
            if (selected === item) {
                index = i;
            }
        });
        return index;
    },

    setSelectedIndex: function(index) {
        var items = this.getPath("content.items");
        if (!items) {
            return -1;
        }
        if (index < 0 && index >= items.length) {
            return this.get("index");
        }
        var item = items.objectAt(index);
        this.set("selectedItem", item); 
        return index;
    },

    prev: function() {
        if (this.get("firstSelected")) {
            return;
        }
        this.set("index", this.get("index") - 1);
    },

    next: function() {
        if (this.get("lastSelected")) {
            return;
        }
        this.set("index", this.get("index") + 1);
    },
});

Bootstrap.NavList = Ember.View.extend({
    tagName: "ul",
    classNames: ["nav nav-list"],
    template: Ember.Handlebars.compile(
        '{{#each content}}' +
          '{{#if divider}}{{view Bootstrap.ListDivider}}{{/if}}' +
          '{{#if header}}{{view Bootstrap.ListHeader contentBinding="header"}}{{/if}}' +
          '{{#each items}}' + 
            '{{view Bootstrap.ListItem contentBinding="this" classBinding="active"}}' +
          '{{/each}}' +
        '{{/each}}'
    ), 
});

Bootstrap.ListHeader = Ember.View.extend({
    tagName: "li",
    classNames: ["nav-header"],
    template: Ember.Handlebars.compile('{{content}}'),
});

Bootstrap.ListDivider = Ember.View.extend({
    tagName: "li",
    classNames: ["divider"], 
});

Bootstrap.ListItem = Ember.View.extend(Ember.TargetActionSupport, {
    tagName: "li",
    template: function() {
        var template;
        if (this.getPath("content.icon")) {
            template = '<a {{bindAttr href="url"}}><i {{bindAttr class="content.icon"}}></i> {{text}}</a>';
        } else {
            template = '<a {{bindAttr href="url"}}>{{text}}</a>';
        }
        return Ember.Handlebars.compile(template);
    }.property(),

    //contentChanged: function() {
    //    if (!this.getPath("parentView.selectedItem")) {
    //        this.setPath("parentView.selectedItem", this.get("content"));
    //    }
    //}.observes("content"),

    text: function() {
        var textPath = this.getPath("parentView.textPath");
        if (!textPath) {
            return this.get("content");
        }
        return this.getPath("content." + textPath);
    }.property("parentView.content.@each").cacheable(),

    url: function() {
        var urlPath = this.getPath("parentView.urlPath");
        if (!urlPath) {
            return "#";
        }
        return this.getPath("content." + urlPath);
    }.property("parentView.content.@each").cacheable(),

    active: function() {
        return this.get("content") === this.getPath("parentView.selectedItem");
    }.property("parentView.selectedItem").cacheable(),

    targetObject: function() {
        var target = this.get("target");
        var root = this.get("templateContext");
        var data = this.get("templateData");

        if (typeof target !== "string") {
            return target;
        }
        return root.getPath(target, {data: data});
    }.property("target").cacheable(),

    target: function() {
        return this.getPath("parentView.target");
    }.property("parentView.target").cacheable(),

    action: function() {
        return this.getPath("parentView.action");
    }.property("parentView.action").cacheable(),

    mouseDown: function() {
        this.setPath("parentView.selectedItem", this.get("content"));
        this.triggerAction();
    },
});

