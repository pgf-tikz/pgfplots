#!/usr/bin/env sh

export PATH=/tmp/texlive/bin/x86_64-linux:$PATH

# Check for cached version
if ! command -v texlua > /dev/null; then
  # Obtain TeX Live
  curl -LO http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
  tar -xzf install-tl-unx.tar.gz
  cd install-tl-20*

  # Install a minimal system
  ./install-tl --profile=../texlive.profile

  # Bump up the main memory
  echo "main_memory = 12435455" >> /tmp/texlive/texmf.cnf

  cd ..
fi

# Update infra first
tlmgr update --self

# Add tlcontrib
tlmgr repository add http://contrib.texlive.info/current tlcontrib || true
tlmgr pinning add tlcontrib "*"

# Install all the required packages
tlmgr install \
    accsupp \
    acrotex \
    amsfonts \
    amsmath \
    atbegshi \
    atveryend \
    auxhook \
    bibtex \
    bitset \
    booktabs \
    colortbl \
    conv-xkv \
    ec \
    epstopdf-pkg \
    etex-pkg \
    etexcmds \
    etoolbox \
    eurosym \
    geometry \
    german \
    graphics \
    hycolor \
    hyperref \
    ifoddpage \
    iftex \
    infwarerr \
    intcalc \
    kvdefinekeys \
    kvoptions \
    kvsetkeys \
    l3kernel \
    l3packages \
    latex \
    latex-bin \
    letltxmacro \
    listings \
    ltxcmds \
    luacode \
    luainputenc \
    luatex \
    luatex85 \
    luatexbase \
    luatodonotes \
    makeindex \
    metafont \
    mfware \
    multido \
    multirow \
    pdfescape \
    pdflscape \
    pdftexcmds \
    pgf \
    pgfplots \
    preview \
    psnfss \
    shellesc \
    soul \
    soulpos \
    standalone \
    todonotes \
    tools \
    units \
    url \
    varwidth \
    vmargin \
    xcolor \
    xkeyval \
    xstring \
    zref

# Keep no backups (not required, simply makes cache bigger)
tlmgr option -- autobackup 0

# Update the TL install but add nothing new
tlmgr update --self --all --no-auto-install

# Install PGF
tlmgr init-usertree --usertree `realpath ..`
export TEXMFHOME=`realpath ..`
