#!/bin/bash

# Ishaan Gulrajani
# June 3 2014
#
# By default, watch for changes in ./coffee and compile ./frontend/app.coffee into
# ./public/app.js every time something changes.
#
# Run with 'release' to disable watching and compile minified JS.

cd "$(dirname "$0")"

export PATH="$(pwd)/../node_modules/.bin:$PATH"

if [ "$1" = "release" ]
then
  export NODE_ENV="production"
  browserify frontend/app.coffee -t coffee-reactify -t envify -t uglifyify \
    -o public/app.js
else
  echo "Watching... ctrl-c to stop"

  export NODE_ENV="development"
  while true
  do

    watchify frontend/app.coffee -v -d -t coffee-reactify -t envify \
      -o public/app.js

    # Error code 130 means ctrl-c, others mean crashed.
    if [ "$?" -eq "130" ]
    then
      echo "Shutting down..."
      exit
    else
      echo "Watchify crashed. Waiting for changes to restart..."
      trap 'echo "Shutting down..."; exit' 2

      # Loop infinitely until /coffee changes
      chsum1=`find frontend/ -type f -exec md5 {} \;`
      chsum2=$chsum1
      while [ "$chsum1" = "$chsum2" ]
      do
        chsum2=`find frontend/ -type f -exec md5 {} \;`
        sleep 1
      done
      
    fi
  done
fi