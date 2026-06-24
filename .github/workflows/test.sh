#!/bin/bash
#
# Runs the pgfplots test suites (lua, unittest, regression) from the top level
# of the repository. With no arguments it runs: lua unittest
#
#   .github/workflows/test.sh [lua] [unittest] [regression]
#
# ALLOWED_FAILURES: space-separated unittest base names allowed to fail
# (default: unittest_luamathparser; see README).

set -u

ALLOWED_FAILURES=${ALLOWED_FAILURES-unittest_luamathparser}

run_lua() {
	echo "==> lua tests"
	make -C source/latex/pgfplots/pgfplotstest/lua_tests/framework/ -f Makefile.luaunit luaunit
	make -C source/latex/pgfplots/pgfplotstest/lua_tests run
}

run_unittest() {
	echo "==> unittest (compile) tests"
	rm -f source/latex/pgfplots/pgfplotstest/unittest/unittest_*.diff.png
	make -C source/latex/pgfplots/pgfplotstest/unittest -k all >/dev/null 2>&1 || true

	local allowed_arr
	read -ra allowed_arr <<< "${ALLOWED_FAILURES}"

	local failed=0 png base a allowed
	for png in source/latex/pgfplots/pgfplotstest/unittest/unittest_*.diff.png; do
		[[ -e "${png}" ]] || continue
		base=$(basename "${png%.diff.png}")
		allowed=0
		for a in "${allowed_arr[@]}"; do
			[[ "${base}" = "${a}" ]] && allowed=1
		done
		if [[ "${allowed}" = 1 ]]; then
			echo "  KNOWN-FAIL ${base} (allowed)"
		else
			echo "  FAIL       ${base}"
			failed=1
		fi
	done
	[[ "${failed}" = 0 ]] && echo "  unittest: OK"
	return "${failed}"
}

run_regression() {
	echo "==> regression (visual diff) tests"
	make -C source/latex/pgfplots/pgfplotstest/regressiontests -k diff
}

SUITES=("$@")
[[ ${#SUITES[@]} -eq 0 ]] && SUITES=(lua unittest)

echo "::group::Install system dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends poppler-utils imagemagick calc
for policy in /etc/ImageMagick-*/policy.xml; do
	[[ -f "${policy}" ]] || continue
	sed -i -E 's@(<policy domain="coder" rights=")none("[^>]*pattern="PDF")@\1read|write\2@' "${policy}"
done
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

rc=0
for suite in "${SUITES[@]}"; do
	echo "::group::Run ${suite} suite"
	case "${suite}" in
		lua)        run_lua        || rc=1 ;;
		unittest)   run_unittest   || rc=1 ;;
		regression) run_regression || rc=1 ;;
		*) echo "unknown suite: ${suite} (expected: lua unittest regression)" >&2; rc=1 ;;
	esac
	echo "::endgroup::"
done

if [[ "${rc}" = 0 ]]; then
	echo "ALL SELECTED SUITES PASSED"
else
	echo "SOME SUITES FAILED" >&2
fi
exit "${rc}"
