#!/bin/bash

elm make Main.elm --output ../web/dict.js
chrome-cli reload -t $(chrome-cli list tabs | grep "Dict v7" | tail -n 1 | awk  -F '[^0-9]+' '{print $2}')
