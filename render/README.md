# CV rendering

`build_cv.sh` compiles the LaTeX CV in place and copies the result to the
published PDF that the homepage and CV link to:

```
../CV_pdf/resume_cisgrad.tex  ──build_cv.sh──▶  ../CV_pdf/resume_cisgrad.pdf  ──copy──▶  files/CV_bh_lee.pdf
```

Run it **after editing `../CV_pdf/resume_cisgrad.tex` and before pushing**, so
the PDF served at `https://hyun1a.github.io/files/CV_bh_lee.pdf` always matches
the source.

## Where the sources live

The LaTeX sources (`resume_cisgrad.tex`, `resume.cls`, older `*_save*.tex`) sit
in `CV_pdf/` **next to this repository, not inside it** — by default
`<repo parent>/CV_pdf`, i.e. `/data3/hyun/career/CV/CV_pdf`. Keeping them out of
the repo means Jekyll can never publish the `.tex` files, and the only CV the
site serves is `files/CV_bh_lee.pdf`.

The compiled PDF is left in `CV_pdf/` next to its source and copied into
`files/CV_bh_lee.pdf`, which is the file to commit.

Point the script elsewhere with `CV_DIR`:

```bash
CV_DIR=/path/to/CV_pdf ./render/build_cv.sh
```

## Usage

From the repository root:

```bash
./render/build_cv.sh
```

Then review `files/CV_bh_lee.pdf` and commit:

```bash
git add files/CV_bh_lee.pdf
git commit -m "Update CV"
git push
```

Only the PDF is committed here; the `.tex` sources are versioned wherever
`CV_pdf/` lives.

## How it works

The CV uses `kotex` (for the ₩ symbol), `academicons` (for the Google Scholar
icon, which requires XeLaTeX/LuaLaTeX), plus `tikz`, `helvet`, `fontawesome5`,
`axessibility`, etc., so a full TeX distribution is needed. To avoid installing
TeX Live locally, the script compiles inside the official `texlive/texlive`
Docker image:

- runs `xelatex` twice (for hyperref bookmarks),
- runs as the current host user (`--user`) so outputs are **not** root-owned,
- mounts `$CV_DIR` (not the repo) into the container,
- leaves `resume_cisgrad.pdf` in `CV_pdf/`, copies it to `files/CV_bh_lee.pdf`,
  and cleans up `.aux/.log/.out`.

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
cd ../CV_pdf && xelatex resume_cisgrad.tex && xelatex resume_cisgrad.tex
cp resume_cisgrad.pdf ../hyun1a.github.io/files/CV_bh_lee.pdf
```
