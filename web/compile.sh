#!/bin/bash

elm make Main.elm --output dict.js
chrome-cli reload -t 11895
