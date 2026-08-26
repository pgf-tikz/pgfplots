#!/usr/bin/env bash
#shellcheck enable=all

set -o errexit
set -o nounset
set -o pipefail

echo "::group::Install system dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends imagemagick
for policy in /etc/ImageMagick-*/policy.xml; do
	[[ -f "${policy}" ]] || continue
	sed -i -E 's@(<policy domain="coder" rights=")none("[^>]*pattern="PDF")@\1read|write\2@' "${policy}"
done
echo "::endgroup::"

echo "::group::Set up TeX Live environment"
# Some CTAN mirrors are rather flaky, so we retry 5 times
attempts=5
for ((i=1; i<=attempts; i++)); do
	tlmgr install acrotex && break
	echo "Attempt ${i}/${attempts} failed."
	if (( i == attempts )); then
		echo "Failed!"
		exit 1
	fi
	echo "Retrying..."
	sleep 1
done
echo "::endgroup::"

echo "::group::Create TeX Live usertree"
if ! [[ -d tlpkg/ ]]; then
	tlmgr init-usertree --usertree "${PWD}"
fi
export "TEXMFHOME=${PWD}"
echo "::endgroup::"

echo "::group::Build the gallery"
if ! nproc="$(nproc)"; then
	nproc=1
fi
make -j "${nproc}" -C doc/latex/pgfplots/gallery all
echo "::endgroup::"

echo "::group::Assemble the gallery for deployment"
rm -rf public
mkdir -p public
cp doc/latex/pgfplots/gallery/gallery.css public/
cp doc/latex/pgfplots/gallery/gallery.html public/
cp doc/latex/pgfplots/gallery/example_* public/
cat > public/index.html <<'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8'>
    <noscript><meta http-equiv="refresh" content="0; url=http://pgfplots.sourceforge.net/"></noscript>
  </head>
  <body onload="window.location.replace('http://pgfplots.sourceforge.net/')">
    If you are not redirected automatically, click <a href="http://pgfplots.sourceforge.net/">this link</a>.
  </body>
</html>
EOF
touch public/.nojekyll
echo "::endgroup::"
