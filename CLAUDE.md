# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

*Le-Point-Technique* is a self-published tutorial/technical journal (ISSN 2826-5726). It is not a software
project — there is no build/test/lint tooling for code. The repository is a collection of Markdown
articles, contributed by different authors, compiled once a year into a single PDF issue via Pandoc + LaTeX.

## Repository structure

- Each yearly issue lives in its own top-level folder: `June2022/`, `June2023/`, `June2024/`, etc.
- Inside a year folder, each article lives in its own subfolder (e.g. `June2024/qsvm/article.md`), generally
  containing the article's `.md` source, an `images/` folder if needed, and sometimes the author's original
  submission (`.docx`/`.pdf`).
- `Sommaire.md` in each year folder is the table of contents, linking to each article's markdown file.
- `notes.md` in each year folder is the short editorial page prepended to the issue.
- `pandoc_defaults.yaml` in each year folder is the Pandoc defaults file that drives the PDF build for that
  issue: it lists `input-files` (editorial notes + each article, in order, plus the shared `ours.md` legal
  notice) and produces `output-file: <Year>.pdf`.
- `head.tex` and `listings-setup.tex` at the repo root are shared LaTeX includes (`include-in-header`) used
  by every year's Pandoc build — e.g. `head.tex` forces a page break at the start of each section.
- `ours.md` is the shared "Mentions légales" (masthead/legal notice) appended to every issue.
- `template.md` is the required article template/boilerplate that new submissions should be based on
  (title, author, abstract, keywords, section structure, figure/table conventions, references style).

## Contribution workflow (from README.md)

1. Fork the repo.
2. Write the tutorial as Markdown following `template.md`, placed in the current year's folder (e.g.
   `June2023/<article-slug>/article.md`).
3. Open a PR against `gcattan/Le-Point-Technique/master`.

Article conventions to follow (see `template.md`):
- Figures are embedded as an image followed by a `<pre>Figure N: legend</pre>` block (note the intentionally
  *unclosed* `</pre>` hack for tables — see below).
- Tables use Pandoc grid-table syntax inside `<div><pre>...</pre></div>` with the closing `</pre>` tag
  deliberately omitted, so tables render as text in GitHub-flavored Markdown while still being parsed
  correctly by Pandoc.
- References use the Chicago Manual of Style, 17th Edition (full note).

## Converting a submission to article.md

When a contributor's folder contains a raw `.docx`/`.pdf` submission next to a still-unedited `article.md`
placeholder, use the local skill `/create-article <year-folder>/<article-slug>` (defined in
`.claude/skills/create-article/SKILL.md`) rather than converting by hand — it codifies the image-extraction,
figure/table formatting, and Pandoc grid-table pitfalls specific to this repo.

## Building a PDF locally

Building requires Pandoc and a full LaTeX toolchain (as used in CI, see below):

```
cd June2024   # or whichever year folder
pandoc -d pandoc_defaults.yaml
```

This produces `<Year>.pdf` per that folder's `pandoc_defaults.yaml` `input-files`/`output-file` settings.
When adding a new article, add its `article.md` path to both `Sommaire.md` and the year's
`pandoc_defaults.yaml` `input-files` list.

Use the local skill `/build-pdf <year-folder>` (defined in `.claude/skills/build-pdf/SKILL.md`) rather than
running this by hand — it also covers installing Pandoc if missing, diagnosing the Unicode/`pdflatex`
failures this repo's articles are prone to, splitting the combined PDF into a per-article PDF in each
article's subfolder (as already done for `June2023/*/article.pdf`), and updating README.md's list of
publications.

## CI (`.github/workflows/`)

- `spellcheck.yml`: runs `rojopolis/spellcheck-github-actions` on every push against all `**/*.md` files,
  using French aspell (`.spellcheck.yaml`) and the custom dictionary `wordlist.txt`. Add any
  intentional/technical words that trip the spellchecker to `wordlist.txt`.
- `git-quality-check.yml`: runs on push to `master`, fails/scores based on bad words in commit messages
  (`WIP`, `todo`) via `gcattan/git-quality-check`; also updates the "Git Quality Score" badge in README.md.
- `publish.yml`: triggered when a PR is labeled `publish`. Installs `texlive-full` and Pandoc, then runs
  `pandoc -d pandoc_defaults.yaml` inside `$FOLDER` (currently hardcoded to `June2022` in the workflow env —
  update this when publishing a new year's issue) and uploads the resulting PDF as a PR artifact.

## Ownership

`.github/CODEOWNERS` restricts merge approval to `@gcattan`; no merges should happen without their approval.
