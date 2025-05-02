#!/usr/bin/env bash

odin build src -out:prog -collection:shared=./lib/ -extra-linker-flags:"-L ./lib/termbox2 -static"
# odin build src -out:prog -collection:shared=./lib/ -define:LIB_TYPE="static" -extra-linker-flags:"-L ./lib/termbox2"
