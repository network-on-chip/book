#!/usr/bin/env bash
# Automated compilation script for Springer Nature Monograph (book.tex)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/4] Running Initial pdflatex Pass ==="
pdflatex -interaction=nonstopmode book.tex > compile.log 2>&1 || {
    echo "Initial pdflatex pass exited with warnings/errors. Inspecting tail of compile.log:"
    tail -n 25 compile.log
}

echo "=== [2/4] Running BibTeX and MakeIndex ==="
bibtex book || true
if [ -f "book.idx" ]; then
    makeindex -s svind.ist book.idx || true
fi

echo "=== [3/4] Running Second pdflatex Pass (Citations & Index) ==="
pdflatex -interaction=nonstopmode book.tex > compile.log 2>&1 || true

echo "=== [4/4] Running Final pdflatex Pass (Cross-References & TOC) ==="
pdflatex -interaction=nonstopmode book.tex > compile.log 2>&1 || {
    echo "Final pdflatex pass had issues. Inspecting tail of compile.log:"
    tail -n 35 compile.log
    exit 1
}

if [ -f "book.pdf" ]; then
    echo "=========================================================="
    echo " Successfully compiled Springer Monograph: book.pdf"
    echo " Location: $SCRIPT_DIR/book.pdf"
    echo " File Size: $(du -h book.pdf | cut -f1)"
    if command -v pdfinfo >/dev/null 2>&1; then
        echo " $(pdfinfo book.pdf | grep -E 'Pages:|PDF version:')"
    fi
    echo "=========================================================="
else
    echo "❌ Error: book.pdf was not produced."
    exit 1
fi
