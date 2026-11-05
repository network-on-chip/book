# Makefile for Springer Nature Monograph

.PHONY: all clean pdf view

all: pdf

pdf:
	bash compile.sh

clean:
	rm -f *.aux *.log *.toc *.idx *.ind *.ilg *.bbl *.blg *.out *.synctex.gz
	rm -f frontmatter/*.aux parts/*.aux chapters/*/*.aux backmatter/*.aux
