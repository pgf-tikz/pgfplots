echo latex:
latex -interaction batchmode -halt-on-error "$@" ||exit 1
echo dvips:
dvips -o "$@.ps" "$@.dvi" ||exit 1
echo ps2pdf "$@.ps":
ps2pdf "$@.ps"
