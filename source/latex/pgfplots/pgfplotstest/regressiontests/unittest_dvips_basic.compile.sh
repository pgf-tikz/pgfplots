latex -shell-escape -interaction batchmode -halt-on-error "$@" && \
latex -shell-escape -interaction batchmode -halt-on-error "$@" && \
dvips -o "$@".ps "$@.dvi" && ps2pdf "$@.ps"
