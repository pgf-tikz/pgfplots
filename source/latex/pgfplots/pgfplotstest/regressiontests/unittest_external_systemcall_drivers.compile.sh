#!/bin/bash
pdflatex -interaction batchmode -halt-on-error -shell-escape "$@" 
