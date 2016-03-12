#!/bin/bash

elm make Main.elm --output ../web/dict.js
chrome-cli reload -t 11895
