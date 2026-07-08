#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "::group::Install system dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends bzip2
echo "::endgroup::"

echo "::group::Set up TeX Live environment"
tlmgr install acrotex
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
while : ; do
	make LATEX="lualatex -shell-escape -halt-on-error -interaction=nonstopmode"
	if ! grep -q -E "(There were undefined references|Rerun to get (cross-references|the bars) right)" -- *.log; then
		break
	fi
	if ! [[ "$(( thisrun=$(( thisrun + 1 )) ))" -lt 5 ]]; then
		echo "::error::Reruns exceeded"
		exit 1
	fi
done
cd -
echo "::endgroup::"

echo "::group::Build package"
make -C .. -f pgfplots/scripts/pgfplots/Makefile.pgfplots_release_sourceforge
echo "::endgroup::"
