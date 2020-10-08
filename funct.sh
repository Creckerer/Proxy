#!/bin/bash
chddir () {
  cd "$PWD/MTProxy"
}
declare -x -f chddir
