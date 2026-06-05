# CV rendering

`build_cv.sh` compiles the LaTeX CV and writes the published PDF that the
homepage and CV link to:

```
CV/resume_cisgrad.tex   ──build_cv.sh──▶   files/CV_bh_lee.pdf
```

Run it **after editing `CV/resume_cisgrad.tex` and before pushing**, so the
PDF served at `https://hyun1a.github.io/files/CV_bh_lee.pdf` always matches the
source.

## Usage

From the repository root:

```bash
./render/build_cv.sh
```

Then review `files/CV_bh_lee.pdf` and commit:

```bash
git add files/CV_bh_lee.pdf CV/resume_cisgrad.tex
git commit -m "Update CV"
git push
```

## How it works

The CV uses `kotex` (for the ₩ symbol), `academicons` (for the Google Scholar
icon, which requires XeLaTeX/LuaLaTeX), plus `tikz`, `helvet`, `fontawesome5`,
`axessibility`, etc., so a full TeX distribution is needed. To avoid installing
TeX Live locally, the script compiles inside the official `texlive/texlive`
Docker image:

- runs `xelatex` twice (for hyperref bookmarks),
- runs as the current host user (`--user`) so outputs are **not** root-owned,
- moves the result to `files/CV_bh_lee.pdf` and cleans up `.aux/.log/.out`.

## Requirements

- Docker. The first run pulls `texlive/texlive:latest` (~5 GB, one-time).
- No network needed after the image is cached.

Override the image if desired:

```bash
TEX_IMAGE=texlive/texlive:latest ./render/build_cv.sh
```

If you already have a local TeX Live with Korean support, you can skip Docker
and compile manually:

```bash
cd CV && xelatex resume_cisgrad.tex && xelatex resume_cisgrad.tex
mv resume_cisgrad.pdf ../files/CV_bh_lee.pdf
```
