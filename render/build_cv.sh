#!/usr/bin/env bash
#
# build_cv.sh — Render the LaTeX CV to files/CV_bh_lee.pdf.
#
# The LaTeX sources live OUTSIDE this repository, in ../CV_pdf (override with
# $CV_DIR). This compiles them in place and then copies the result to
# files/CV_bh_lee.pdf, the PDF linked from the homepage and CV.
# Run it locally after editing the CV and BEFORE pushing to the remote,
# so the published PDF always matches the source.
#
# Requirements: Docker (a full TeX Live image is used, so no local LaTeX
# install is needed). No network is required once the image is pulled.
#
# Usage:
#   ./render/build_cv.sh                 # build with the default settings
#   CV_DIR=/path/to/CV_pdf ./render/build_cv.sh             # override source dir
#   TEX_IMAGE=texlive/texlive:latest ./render/build_cv.sh   # override image
#
set -euo pipefail

# --- Paths -------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# LaTeX sources (resume.cls + the .tex). Outside the repo by default, so the
# sources are never published by Jekyll.
CV_DIR="${CV_DIR:-$(cd "${REPO_ROOT}/.." && pwd)/CV_pdf}"
TEX_NAME="resume_cisgrad"         # source file (without .tex)
OUT_PDF="files/CV_bh_lee.pdf"     # published copy (relative to repo root)

TEX_IMAGE="${TEX_IMAGE:-texlive/texlive:latest}"

# --- Sanity checks -----------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not on PATH." >&2
  echo "Install Docker, or compile manually with: cd ${CV_DIR} && xelatex ${TEX_NAME}.tex" >&2
  exit 1
fi

if [ ! -f "${CV_DIR}/${TEX_NAME}.tex" ]; then
  echo "ERROR: ${CV_DIR}/${TEX_NAME}.tex not found." >&2
  echo "Set CV_DIR to the directory holding ${TEX_NAME}.tex and resume.cls." >&2
  exit 1
fi

if ! docker image inspect "${TEX_IMAGE}" >/dev/null 2>&1; then
  echo ">> Pulling TeX Live image (${TEX_IMAGE}); this is a one-time download..."
  docker pull "${TEX_IMAGE}"
fi

echo ">> Compiling ${CV_DIR}/${TEX_NAME}.tex with ${TEX_IMAGE} ..."

# Run as the current host user so output files are not owned by root.
# HOME/TEXMFVAR are redirected to a writable tmp dir for the font cache.
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e TEXMFVAR=/tmp/texmf-var \
  -v "${CV_DIR}":/work \
  -w /work \
  "${TEX_IMAGE}" \
  sh -c "xelatex -interaction=nonstopmode -halt-on-error ${TEX_NAME}.tex >/tmp/cv_build.log 2>&1 \
      && xelatex -interaction=nonstopmode -halt-on-error ${TEX_NAME}.tex >/tmp/cv_build.log 2>&1 \
      || { echo '--- LaTeX errors ---'; grep -nE '^!|Error|Undefined' /tmp/cv_build.log | head -40; exit 1; }"

# --- Publish + clean ---------------------------------------------------------
# The compiled PDF stays in ${CV_DIR} next to its source; files/ gets the copy
# that the site actually serves.
mkdir -p "${REPO_ROOT}/files"
cp -f "${CV_DIR}/${TEX_NAME}.pdf" "${REPO_ROOT}/${OUT_PDF}"

# Remove LaTeX build artifacts (the PDF is kept).
rm -f "${CV_DIR}/${TEX_NAME}".{aux,log,out,toc,fls,fdb_latexmk,synctex.gz} 2>/dev/null || true

echo ">> Done. Built ${CV_DIR}/${TEX_NAME}.pdf and copied it to ${OUT_PDF}"
echo ">> Review it, then commit and push:"
echo "     git add ${OUT_PDF} && git commit -m 'Update CV' && git push"
