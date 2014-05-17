#!/bin/bash
latex -interaction batchmode -halt-on-error -shell-escape "$@" && dvips -o "$@".ps "$@".dvi && ps2pdf "$@".ps "$@".pdf
