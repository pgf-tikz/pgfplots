latex -interaction batchmode -halt-on-error "$@" && dvipdfmx "$@.dvi"
