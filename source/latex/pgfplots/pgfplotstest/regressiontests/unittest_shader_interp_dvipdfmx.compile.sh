# -z 0   : no compression
# -V 4   : turn off object streams - simpler to debug
latex -interaction batchmode -halt-on-error "$@" && dvipdfmx "$@.dvi"
