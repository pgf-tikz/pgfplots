latex -interaction batchmode -halt-on-error "$@" && dvips -o "$@.ps" "$@.dvi" && pstopdf "$@.ps"
