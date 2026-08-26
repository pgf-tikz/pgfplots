#!/usr/bin/env bash
#shellcheck enable=all

set -o errexit
set -o nounset
set -o pipefail

echo "::group::Install system dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends bzip2
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

echo "::group::Generate the revision file"
bash scripts/pgfplots/pgfplotsrevisionfile.sh
cat tex/generic/pgfplots/pgfplots.revision.tex
export "GIT_TAG=$(git describe --abbrev=0 --tags)"
echo "::endgroup::"

echo "::group::Build the manual"
cd doc/latex/pgfplots
thisrun=0
if ! nproc="$(nproc)"; then
	nproc=1
fi
while : ; do
	make -j "${nproc}" LATEX="lualatex -shell-escape -halt-on-error -interaction=nonstopmode"
	if ! grep -q -E "(There were undefined references|Rerun to get (cross-references|the bars) right)" -- *.log; then
		break
	fi
	if [[ "$(( thisrun=$(( thisrun + 1 )) ))" -ge 5 ]]; then
		echo "::error::Reruns exceeded"
		exit 1
	fi
done
cd -
echo "::endgroup::"

echo "::group::Build package"
VERSION="_$(git describe --tags --always --dirty)"
export VERSION
make -C .. -f pgfplots/scripts/pgfplots/Makefile.pgfplots_release_sourceforge
echo "::endgroup::"

echo "::group::Collect artifacts"
mkdir -pv artifacts
mv -v -t artifacts ../pgfplots*.pdf ../pgfplots*.zip
echo "::endgroup::"
