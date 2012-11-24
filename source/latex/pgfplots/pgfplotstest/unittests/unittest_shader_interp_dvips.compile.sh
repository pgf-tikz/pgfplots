latex -interaction batchmode -halt-on-error "$@" && dvips -o "$@.pdf" "$@.dvi"
