---
name: create-article
description: Convert a contributor's submitted source document (.docx or .pdf) into an article.md following template.md and this repo's house style. Use when a year folder (June2024/, June2025/, ...) contains an article subfolder with a raw .docx/.pdf submission that still needs to become article.md, or when article.md is still the unedited placeholder template.
argument-hint: <year-folder>/<article-slug>  (e.g. June2024/qsvm)
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - PowerShell
  - AskUserQuestion
---

# Create article.md

Convert a contributor's raw submission (`.docx` or `.pdf`, usually sitting next to a placeholder `article.md`) into a finished `article.md` that follows `template.md` and matches the style of already-published articles in this repo (see `June2023/backend_for_frontend/backend_for_frontend.md` or `June2024/etud_exp_collab/article.md` for reference).

## Usage

`/create-article <year-folder>/<article-slug>`

Example: `/create-article June2024/qsvm`

The target folder must contain the source submission (`.docx` and/or `.pdf`, and optionally the original `article.md` placeholder copied from `template.md`).

## Step 1 — Read the house style

Read `template.md` (repo root) to refresh the required structure:
- `\setcounter{figure}{0}` on line 1.
- `# Title`, then `_Firstname Lastname_`, then `_Le-Point-Technique_, _MM/YYYY_` (MM/YYYY = the month/year of the target issue — infer from the year folder name and, if the source document states a submission month, use that).
- `__abstract__: ...` and `__keywords__: ...` lines.
- Section headings (`##`, `###`) — reuse the author's own section structure/numbering rather than forcing "Section I / Section II".
- Figures: `> ![caption](images/image-N.png)` immediately followed by `> <pre>\n> Figure N: legend\n> </pre>`.
- Tables: pandoc grid-table syntax wrapped in `<div><pre>...</pre></div>` with the closing `</pre>` **deliberately omitted** (this is intentional — see Step 5).
- References in Chicago Manual of Style, 17th ed. (full note) format.

Also skim one real published article (e.g. `June2023/backend_for_frontend/backend_for_frontend.md`) to confirm tone/formatting in practice.

## Step 2 — Extract the source content

Check what source file(s) exist in the target folder with Glob.

**If a `.docx` source exists:**

First check whether `pandoc` is available (`Get-Command pandoc -ErrorAction SilentlyContinue` in PowerShell). If it is, prefer it:
```
pandoc "<source>.docx" -t markdown --wrap=none --extract-media=./_pandoc_extract -o _pandoc_extract/raw.md
```

If pandoc is **not** available (common on a bare Windows checkout), fall back to Word COM automation via PowerShell — this repo has confirmed this works even without Word being scriptable through any other means:

```powershell
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open("<absolute path to .docx>", $false, $true)
foreach ($p in $doc.Paragraphs) {
  $style = $p.Range.Style.NameLocal   # NOTE: property access, NOT $p.Range.get_Style() — that throws in PS 5.1
  $text = ($p.Range.Text -replace "`r","" -replace "`a","").TrimEnd()
  "[$style] $text"
}
$doc.Close([ref]$false)
$word.Quit()
```

Use the paragraph style names (`Title`, `Heading 1`/`Heading 2`/..., `Normal`) to reconstruct the section hierarchy.

To locate and order embedded images/figures, inspect **both** collections — inline images and floating (anchored) images are reported separately by Word and a document commonly uses both:

```powershell
foreach ($shape in $doc.InlineShapes) { $shape.Range.Start; $shape.Range.Paragraphs(1).Range.Text }
foreach ($shape in $doc.Shapes)       { $shape.Name; $shape.Anchor.Paragraphs(1).Range.Text }
```

Match each shape to the nearest surrounding paragraph text (often a "Figure N. ..." caption) to determine reading order and figure numbers. The `Shapes.Name` sometimes still carries the original media filename (e.g. `image4.jpg`) — use that to map back to `word/media/imageN.*` inside the docx (a `.docx` is a zip; `Expand-Archive` after copying to `.zip` extension exposes `word/media/`).

**Do not guess which extracted image is which figure.** Use the Read tool to actually view every candidate image before deciding placement — filenames and shape order do not reliably match final document order (assets get reordered by copy/paste during authoring). Skip decorative images (institution logos, generic icons) that don't correspond to a captioned figure in the text.

**If a `.pdf` source exists** (and no usable `.docx`): try the Read tool directly first (page by page, using the `pages` parameter for documents over ~10 pages). If it fails with `pdftoppm is not installed`, the Read tool's renderer isn't on PATH — don't install anything, first check for poppler binaries already present elsewhere on the machine (e.g. bundled with SourceTree, MiKTeX, or Git for Windows): `Get-Command pdftotext, pdftoppm, pdfimages -ErrorAction SilentlyContinue`. If found, call them directly instead of going through Word COM (no need to convert PDF→docx, which is slow and can hang on a confirmation dialog):
- `pdftotext -layout -enc UTF-8 <src>.pdf <out>.txt` for the body text (note: if the source path has non-ASCII characters, copy it to a plain-ASCII temp filename first — some builds mis-handle Unicode argv on Windows).
- `pdfimages -png <src>.pdf <outdir>/img` to pull embedded raster images (won't catch vector-drawn diagrams).
- For vector diagrams (flowcharts, UML, etc. drawn directly in the source app, not embedded as a picture): render the specific page at high DPI (`pdftoppm -png -r 300 -f <n> -l <n> <src>.pdf <out>`), view it with Read, then crop to the diagram's bounding box with `System.Drawing.Bitmap` in PowerShell (`Bitmap.Clone(Rectangle, ...)`) — iterate the crop rectangle by viewing the result and adjusting ratios until the border is clean.

If no poppler binary is available anywhere, only then fall back to Word COM (`Documents.Open` accepts `.pdf` and reflows it into an editable document) — expect it to be slow and check the background task rather than blocking.

## Step 3 — Place images

Create `<article-folder>/images/` if it doesn't exist. Save each figure that will be referenced in the article as `image-1.<ext>`, `image-2.<ext>`, ... in final figure order (extension matches the source — `.png`/`.jpg` are both fine, no need to convert). Do not keep unused/decorative images.

## Step 4 — Write article.md

Write `<article-folder>/article.md` per the Step 1 structure:
- Translate the author's section/subsection headings into `##`/`###`, preserving their numbering scheme.
- Write a French or English abstract/keywords as appropriate to the source language — match the source document's language, don't translate the whole article.
- Insert each figure at the point in the text where it's discussed, using the exact blockquote+pre figure convention.
- Carry over the bibliography, converting to Chicago 17th (full note) style. If the source only has bare URLs/DOIs, format them as `Author. Year. 'Title'. Source. DOI/URL.` as best-effort. If the source genuinely has no reference list (common for internal client deliverables), say so explicitly rather than leaving a bare placeholder.

If the source is French, expect **non-breaking spaces (U+00A0)** before `:`, `;`, `!`, `?` (standard French typography, and what Word/`pdftotext` both emit). This looks identical to a regular space when read back, but an `Edit` `old_string` typed with an ordinary space will silently fail to match. When an `Edit` on French text fails unexpectedly, don't retry the same string — check for this first (`[System.Text.Encoding]::UTF8.GetBytes($line) | %{$_.ToString("X2")}` in PowerShell shows `C2 A0` where a space looks like it should be), and anchor the edit on a substring that avoids the punctuation, or splice lines via `Get-Content`/`Set-Content` instead of `Edit` when it keeps failing.

## Step 5 — Build grid tables correctly (if any tables are needed)

Do **not** hand-type ASCII table borders — column-width mismatches between the header separator and body rows silently break Pandoc's grid-table parser. Generate them with a short PowerShell snippet instead, then paste the result in between `<div><pre>` / `</div>`:

```powershell
$rows = @(("Col A","Col B"), ("val1","val2"))   # first row = header
$w1 = ($rows | ForEach-Object { $_[0].Length } | Measure-Object -Maximum).Maximum + 2
$w2 = ($rows | ForEach-Object { $_[1].Length } | Measure-Object -Maximum).Maximum + 2
function Border($ch) { "+" + ($ch * $w1) + "+" + ($ch * $w2) + "+" }
function Line($a,$b) { "|" + (" $a").PadRight($w1) + "|" + (" $b").PadRight($w2) + "|" }
Border "-"; Line $rows[0][0] $rows[0][1]; Border "="
for ($i=1; $i -lt $rows.Length; $i++) { Line $rows[$i][0] $rows[$i][1]; Border "-" }
```
Prefix every output line with `> ` when pasting into the article. Remember the closing `</pre>` after `</div>` is intentionally omitted (matches `template.md`).

## Step 6 — Register the article in the issue

Check the year folder's `Sommaire.md` and `pandoc_defaults.yaml`:
- `Sommaire.md` needs a numbered link entry: `N. [Title](<slug>/article.md)`.
- `pandoc_defaults.yaml`'s `input-files:` list needs `<slug>/article.md` added, in the same order as `Sommaire.md`.

Add either if missing; leave them alone if the article is already registered (it usually already is, since the placeholder was created as part of issue setup).

## Step 7 — Clean up and report

Delete any temporary extraction scratch directories you created. Report to the user:
- Word count / section count of the resulting article.
- How many figures/tables were placed, and any figure from the source you deliberately dropped (decorative-only) or couldn't confidently place — flag those for human review rather than guessing.
- Whether `Sommaire.md`/`pandoc_defaults.yaml` needed updates.

Do not delete or modify the original `.docx`/`.pdf` source file — it stays in the folder as the submission record.
