auto_ref.tex: Makefile auto_ref.lyx
	rm -f $@
	lyx -e pdflatex auto_ref.lyx
intro.tex: Makefile intro.lyx
	rm -f $@
	lyx -e pdflatex intro.lyx
define PYMAKEAUTOREFCITES
import sys,re
inside=False
inside_my=False
occured=set()
def normalizecmdname(name):
	return re.sub(r"[\d\._:-]","",name)
def singlereplacer(name):
	if name in occured: return r"{\textsuperscript{\ref{numref"+name+r"}}}"
	occured.add(name)
	return "{\\autorefcite"+name+"}"
replacer=lambda match: r"\!"+r"\textsuperscript{,}".join((singlereplacer(normalizecmdname(book)) for book in match.group(1).split(",")))
for in_line in sys.stdin:
	if in_line.startswith(r"\end{document}"):
		inside=False
	if not inside:		
		if in_line.startswith(r"\begin{document}"):
			inside=True
	else:
		if in_line.startswith("Результаты автора"):
			inside_my=True
		if not inside_my:
			in_line=re.sub(r"\\cite{([^}]+)}",replacer,in_line)
		sys.stdout.write(in_line)
endef
export PYMAKEAUTOREFCITES
intro_for_autoref.tex: Makefile intro.tex
	python -c "$$PYMAKEAUTOREFCITES" < intro.tex >$@ 
define PYMAKEAUTOREFBIB
import sys,re
inside_def=False
def normalizecmdname(name):
	return re.sub(r"[\d\._:-]","",name)
def replacer(match):
	global inside_def
	inside_def=True
	name=normalizecmdname(match.group(1))
	return "\\newcommand{\\autorefcite"+name+r"}{\footnote{\label{numref"+name+"}"
for in_line in sys.stdin:
	if len(in_line.strip("\n")) == 0:
		if inside_def:
			inside_def=False
			in_line="}}"+in_line
		sys.stdout.write(in_line)
	else:
		sys.stdout.write(re.sub(r"\\bibitem{([^}]+)}",replacer,in_line))
endef
export PYMAKEAUTOREFBIB
autoref_bibcommands_generator.tex: Makefile autoref_bibcommands_generator.aux f5_references.bib gost/ugost2008s.bst
	rm autoref_bibcommands_generator.bbl
	bibtex autoref_bibcommands_generator.aux
	grep -v "thebibliography" < autoref_bibcommands_generator.bbl| python -c "$$PYMAKEAUTOREFBIB" >$@
auto_ref.pdf: autoref_bibcommands_generator.tex intro_for_autoref.tex auto_ref.tex Makefile
	pdflatex auto_ref.tex
	bibtex auto_ref.1.aux
	pdflatex auto_ref.tex
	pdflatex auto_ref.tex	
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
origf5_termination_small.tex: origf5_termination_small.lyx Makefile
	rm -f $@
	lyx -e pdflatex $<
f5_references_1251.bib: f5_references.bib Makefile
	iconv -t cp1251 $< > $@
origf5_termination_vestnik.tex: origf5_termination_small.tex Makefile
	cpp -traditional-cpp -P -DVESTNIK $< | sed \
	-e 's/\\label{eq:spair-chain}/\\tag{1}/' \
	-e 's/\\eqref{eq:spair-chain}/(1)/' \
	-e 's/{proof}/{proofwithpar}/' \
	>$@
origf5_termination_full.pdf: origf5_termination_ru.tex vestnik.bst f5_references_1251.bib
	rm -f origf5_termination_ru.aux origf5_termination_ru.bbl
	pdflatex $<
	bibtex8 -B -c gost/cp1251.csf origf5_termination_ru || true
	pdflatex $<
	pdflatex $<
	mv origf5_termination_ru.pdf $@
define PYVESTNIKBIB
import sys,re
cites=[]
bibl=[]
for bibline in open(sys.argv[2]):
	m = re.search("bibitem{([^}]+)}",bibline)
	if m: cites.append(m.group(1))
	else: bibl.append(re.sub("authorsit","wref{"+str(len(bibl)+1)+"}",bibline))
replacer=lambda match: "{[}"+",".join((str(num) for num in sorted(1+cites.index(book) for book in match.group(1).split(","))))+"{]}"
#sys.stdout.write(str(cites)+str(bibl))
with_cites=re.sub(r"\\cite{([^}]+)}",replacer,open(sys.argv[1]).read())
with_bibl=with_cites.replace(r"""
\bibliographystyle{vestnik}
\bibliography{f5_references_1251}""",
r"\wrefdef{"+str(len(bibl))+"}\n"+
"\n".join(bibl))

sys.stdout.write(with_bibl)

endef
export PYVESTNIKBIB

origf5_termination_vestnik.pdf: origf5_termination_vestnik.tex vestnik.bst f5_references_1251.bib
	rm -f origf5_termination_vestnik.aux origf5_termination_vestnik.bbl
	pdflatex $<
	rm $@
	bibtex8 -B -c gost/cp1251.csf origf5_termination_vestnik || true
	tr '\n' '\t' < origf5_termination_vestnik.bbl | sed 's/\t  / /g' | tr '\t' '\n' |grep -e '\(^\\authorsit\|bibitem\)' > origf5_termination_vestnik_filtered.bbl
	python -c "$$PYVESTNIKBIB" $< origf5_termination_vestnik_filtered.bbl > $<.pyvestnikbib.tex
	pdflatex $<.pyvestnikbib.tex
	pdflatex $<.pyvestnikbib.tex
	mv $<.pyvestnikbib.pdf $@
	cp $<.pyvestnikbib.tex origf5_termination_for_publish.tex
	cp $@ origf5_termination_for_publish.pdf
view-origf5_termination_full: origf5_termination_full.pdf
	make clean-logs
	xdg-open $^
view-origf5_termination_vestnik: origf5_termination_vestnik.pdf
	make clean-logs
	xdg-open $^
clean: clean-logs
	rm -f *.tex *.bbl *.pdf f5_references_1251.bib
