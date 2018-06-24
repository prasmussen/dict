#!/bin/bash
set -e

fswatch -d -r -o src | xargs -n 1 bash -c 'clear && ./build.sh&'
