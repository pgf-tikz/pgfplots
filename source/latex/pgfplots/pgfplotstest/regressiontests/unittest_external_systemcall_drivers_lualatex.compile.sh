#!/bin/bash
lualatex -interaction batchmode -halt-on-error -shell-escape "$@" 
