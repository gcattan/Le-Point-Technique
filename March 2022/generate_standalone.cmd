pandoc -d pandoc_defaults.yaml

REM pandoc --css pandoc.css --pdf-engine=wkhtmltopdf -f commonmark -t pdf v1.md > v1.pdf