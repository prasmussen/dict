#!/bin/bash

fswatch -o *.elm | xargs -n 1 ./compile.sh
