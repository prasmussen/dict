#!/bin/bash

elm make DictApp.elm --output dict.js
chrome-cli reload -t 11895
