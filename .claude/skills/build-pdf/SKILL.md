---
name: build-pdf
description: Build the compiled JuneYEAR.pdf issue from a year folder's pandoc_defaults.yaml (e.g. June2024/June2024.pdf). Use when asked to build, generate, compile, or render the PDF for a given year's issue of this journal.
argument-hint: <year-folder>  (e.g. June2024)
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - PowerShell
  - AskUserQuestion
---

# Build JuneYEAR.pdf

Build the compiled issue PDF for a year folder (e.g. `June2024/June2024.pdf`) using that folder's `pandoc_defaults.yaml`, per the documented process in `CLAUDE.md`.

## Usage

`/build-pdf <year-folder>`

Example: `/build-pdf June2024`

## Step 1 — Check the toolchain

Check whether `pandoc` and a LaTeX engine (`pdflatex`, from a MiKTeX/TeX Live install) are available:

```powershell
Get-Command pandoc -ErrorAction SilentlyContinue
Get-Command pdflatex -ErrorAction SilentlyContinue
```

- If `pdflatex` is missing, a full LaTeX toolchain install is a large, disruptive action — stop and tell the user, don't attempt it.
- If `pandoc` is missing, **ask the user first** (`AskUserQuestion`) whether to install it via `winget install --id JohnMacFarlane.Pandoc -e --accept-package-agreements --accept-source-agreements` — this modifies the machine outside the repo, so don't do it silently even though it's low-risk.

**Windows PATH gotcha**: a fresh `winget install` updates the Machine/User PATH registry values, but the *current* PowerShell process won't see it, and each tool call here is a fresh process anyway (shell state doesn't persist between calls). Always refresh PATH at the start of the same command that uses `pandoc`/`pdflatex`:
```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
```

## Step 2 — Run the build

From the year folder, capture full output to a log file rather than the console (pandoc/LaTeX output is long and the console tool may truncate it, hiding the actual error):

```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
Set-Location "<year-folder>"   # only if not already there — check Get-Location first, Set-Location into an already-current dir errors
pandoc -d pandoc_defaults.yaml > "$env:TEMP\pandoc_build.log" 2>&1
Write-Output "EXIT: $LASTEXITCODE"
```

If `$LASTEXITCODE` is 0 and `<Year>.pdf` now exists, skip to Step 4. Otherwise go to Step 3.

## Step 3 — Diagnose and fix a failed build

Grep the log for the real error, not just the tail (pandoc dumps the full generated LaTeX source to the log when `pdflatex` fails, which buries the actual message):

```powershell
Select-String -Path "$env:TEMP\pandoc_build.log" -Pattern "^!|Fatal error|Error producing PDF" 
```

The most common failure in this repo is **`pdflatex` choking on a raw Unicode character** that pandoc's LaTeX writer doesn't auto-escape (it does handle em/en dashes, curly quotes, ellipsis, non-breaking spaces automatically — but math/comparison symbols and Greek letters pass through raw and break `pdflatex`'s default encoding). The error looks like:
```
! LaTeX Error: Unicode character X (U+xxxx)
```
Find every instance of that character across the year's articles and reword it out of the Markdown source (don't touch `pandoc_defaults.yaml`'s `pdf-engine` — switching to `xelatex`/`lualatex` is a bigger, repo-wide change, not a per-build fix):

```powershell
Get-ChildItem -Path "<year-folder>" -Filter "*.md" -Recurse | Select-String -Pattern "<the character>"
```
Reasonable rewordings used before in this repo: `≥17` → `17 ou plus`, `A → B` → `A, d'où B`, `β` → `bêta` (spelled out). Prefer plain words over hunting for a LaTeX-escapable equivalent — these are prose articles, not math papers.

Re-run Step 2 after each fix. Repeat until the build succeeds — there is often more than one offending character.

## Step 4 — Visually verify the output

Don't just trust exit code 0 — confirm the PDF actually looks right. The Read tool's built-in PDF page renderer needs `pdftoppm` on PATH and will fail with "pdftoppm is not installed" even when a poppler binary exists elsewhere on the machine (e.g. bundled with MiKTeX or SourceTree — see `create-article`'s Step 2 for how to locate one). Render pages yourself and view them with Read:

```powershell
$pdftoppm = "<path to pdftoppm.exe found earlier>"
& $pdftoppm -png -r 100 "<Year>.pdf" "$env:TEMP\pdf_check\p"
```

Check at minimum: the table of contents page, one page per article containing a figure (confirms images embedded correctly), and one page containing a table (confirms grid-table syntax parsed correctly — a bad grid table either throws a pandoc parse error earlier, or silently renders as a literal code block, so a visual check matters even after a clean exit code).

Clean up the temp render directory and log file afterward.

## Step 5 — Split into per-article PDFs

Some year folders keep a standalone PDF of just one article inside its own subfolder, extracted from the combined issue PDF — see `June2023/api_rest_http/article.pdf`, `June2023/backend_for_frontend/article.pdf`, `June2023/notes_llm/article.pdf`. Do this for the year you just built too, for consistency, unless every article subfolder in this year already has its own `article.pdf` (then skip — don't regenerate unasked).

1. Reuse the poppler install located in Step 4 — the same folder as `pdftoppm.exe` also has `pdftotext.exe`, `pdfinfo.exe`, `pdfseparate.exe`, and `pdfunite.exe`.
2. Find each article's first page by searching page-by-page for its byline text. Each article's `_Le-Point-Technique_, _MM/YYYY_` line (directly under the title) renders as a unique `Le-Point-Technique, <Month/Year>` string that appears exactly once in the combined PDF, on its title page — unlike the title itself, this string does *not* also appear in the table of contents, so it's a reliable per-page marker:
   ```powershell
   & $pdfinfo "<Year>.pdf"   # read "Pages:" for the total page count
   for ($p = 1; $p -le $totalPages; $p++) {
     $text = & $pdftotext -f $p -l $p "<Year>.pdf" -
     if ($text -match "Le-Point-Technique,") { "page $p" }
   }
   ```
   Match the found pages, in order, against `Sommaire.md`'s article order for that year.
3. Each article's last page is (next article's first page − 1); for the final article, it's (first page of the `ours.md` "Mentions Légales" section − 1) if present, otherwise the document's last page.
4. Extract the page range per article with `pdfseparate` + `pdfunite` (don't hand-roll page extraction another way — these two are already available and page-range-accurate):
   ```powershell
   & $pdfseparate -f $startPage -l $endPage "<Year>.pdf" "$tmp\page-%d.pdf"
   & $pdfunite (Get-ChildItem "$tmp\page-*.pdf" | Sort-Object { [int]([regex]::Match($_.Name,'\d+').Value) }) "<article-folder>\article.pdf"
   ```
5. Visually spot-check at least one extracted `article.pdf` (its first and last rendered page) to confirm the boundary landed correctly — an off-by-one here is easy to make and won't throw an error, it'll just silently include a stray page from the neighboring article or cut off the last page.

## Step 6 — Update README.md's "List of publications"

Read the root `README.md`. Under `# List of publications`, each year is a block:
```
[June YYYY](YearFolder/YearFolder.pdf)
- _Author Name_, Title, [DOI](...) or [Article](https://github.com/gcattan/Le-Point-Technique/blob/master/<YearFolder>/<slug>/article.pdf)
```

- If a `[June YYYY](...)` heading for this year **already exists**, leave it — don't duplicate or reorder it. At most check its article bullets match the current `Sommaire.md` (flag any mismatch to the user, don't silently rewrite an existing entry).
- If it **doesn't exist yet**, append a new block at the end of the list (years are in chronological order), built from the year's `Sommaire.md` order:
  - Heading: `[June YYYY](<YearFolder>/<YearFolder>.pdf)`.
  - One bullet per article, in `Sommaire.md` order: pull the author name(s) from the `_Name, Surname_` byline line and the title from the `# Title` line at the top of each `article.md`.
  - Link target: use a `[DOI](...)` only if the article's own References/metadata already states one was minted for *this* article (rare at build time). Otherwise link to the per-article PDF produced in Step 5, as `[Article](https://github.com/gcattan/Le-Point-Technique/blob/master/<YearFolder>/<slug>/article.pdf)` — this is the actual precedent (see the "Notes on Large Language Models" entry for June 2023, which links `notes_llm/article.pdf` and has no DOI), not a link to the `.md` source.
- Tell the user explicitly that DOI links are a manual follow-up (minting one requires the author registering the article on Zenodo, which is outside this skill's scope) — don't invent or guess a DOI.

## Step 7 — Report

Tell the user: page count and file size of the combined PDF, which per-article PDFs were (re)generated, what (if anything) was reworded in the source Markdown to make the build succeed, and what was added to README.md. Rewording source content is a real change to the article, not just a build artifact, so it's worth surfacing even though the task was "build the PDF." Don't commit the generated PDFs unless asked; they're build artifacts, not part of the normal contribution workflow (CI only produces the combined PDF as a PR artifact on demand, gated by the `publish` label).
