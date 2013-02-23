latex -interaction batchmode -halt-on-error "$@" && dvips -o "$@.ps" "$@.dvi" && ps2pdf "$@.ps"
