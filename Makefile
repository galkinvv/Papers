simple_sig_rus.tex: simple_sig_rus.lyx Makefile
	rm -f $@
	lyx -e pdflatex simple_sig_rus.lyx
simple_sig.tex: simple_sig.lyx Makefile
	rm -f $@
	lyx -e pdflatex simple_sig.lyx
define PYREPLACE
import sys,re
cites=(
"FaugereF5",
"KreuzerRobbianoBook1",
"TheF5Revised",
"GermanF5Proof",
"ZobninGeneralization",
"F5InBBStyle",
"G2V",
"SignatureBasedGBs",
"F5C",
"HuangConception",
"PracticalGB"
)
replacer=lambda match: "{[}"+",".join(sorted(str(1+cites.index(book)) for book in match.group(1).split(",")))+"{]}"
sys.stdout.write(re.sub(r"\\cite{([^}]+)}",replacer,sys.stdin.read()))
endef
export PYREPLACE
simple_sig_rus.vestnik.tex: simple_sig_rus.tex
	python -c "$$PYREPLACE" <$^|sed\
		-e 's/\\label{eq:gvw-order-3}/\\tag{1}/'\
		-e 's/\\eqref{eq:gvw-order-3}/(1)/'\
		-e 's/\\label{eq:left-or-right-monom}/\\tag{2}/'\
		-e 's/\\eqref{eq:left-or-right-monom}/(2)/'\
		-e 's/\\vestnikonly}\[1\]{}/\\vestnikonly}[1]{#1}/'\
		-e 's/\\novestnikonly}\[1\]{#1}/\\novestnikonly}[1]{}/'\
		-e 's/\(\\usepackage\[unicode=true\]\|{hyperref}\)/% \0/'\
		> $@
simple_sig_rus.vestnik.pdf: simple_sig_rus.vestnik.tex
	pdflatex $^
	pdflatex $^
simple_sig_rus.pdf: simple_sig_rus.tex  f5_references.bib
	pdflatex $^
	bibtex simple_sig_rus.aux
	pdflatex $^
	pdflatex $^
simple_sig.pdf: simple_sig.tex  f5_references.bib
	pdflatex $^
	bibtex simple_sig.aux
	pdflatex $^
	pdflatex $^
clean-logs:
	rm -f *.aux *.log *.out *.blg *~
view-vestnik: simple_sig_rus.vestnik.pdf
	make clean-logs
	xdg-open $^
view-rus: simple_sig_rus.pdf
	make clean-logs
	xdg-open $^
view: simple_sig.pdf
	make clean-logs
	xdg-open $^
origf5_termination.tex: origf5_termination.lyx Makefile
	rm -f $@
	lyx -e pdflatex $<
origf5_termination.pdf: origf5_termination.tex short.bst f5_references.bib
	rm -f origf5_termination.aux  origf5_termination.bbl
	pdflatex $<
	bibtex origf5_termination.aux
	pdflatex $<
	pdflatex $<
view-origf5_termination: origf5_termination.pdf
	make clean-logs
	xdg-open $^
origf5_termination_ru.tex: origf5_termination_ru.lyx Makefile
	rm -f $@
	lyx -e pdflatex $<
f5_references_1251.bib: f5_references.bib Makefile
	iconv -t cp1251 $< > $@
origf5_termination_ru.pdf: origf5_termination_ru.tex vestnik.bst f5_references_1251.bib
	rm -f origf5_termination_ru.aux origf5_termination_ru.bbl
	pdflatex $<
	bibtex8 -B -c gost/cp1251.csf origf5_termination_ru || true
	pdflatex $<
	pdflatex $<
view-origf5_termination_ru: origf5_termination_ru.pdf
	make clean-logs
	xdg-open $^
clean: clean-logs
	rm -f *.tex *.bbl *.pdf f5_references_1251.bib
