vgalkin_disser.pdf: vgalkin_disser.lyx intro.lyx my_publications.bib f5_references.bib
	lyx -e pdf4 $<
auto_ref_plainrefs.tex: Makefile auto_ref.lyx
	rm -f $@
	lyx -e xetex auto_ref.lyx
	mv auto_ref.tex auto_ref_plainrefs.tex
intro.tex: Makefile intro.lyx my_publications.bib
	rm -f $@
	lyx -e pdflatex intro.lyx
define PYMAKEAUTOREFCITES
import sys,re
all_doc="--alldocument" in sys.argv
inside=False
inside_my=False
def normalizecmdname(name):
	return re.sub(r"[\d\._:0-9-]","X",name)
def singlereplacer(name):
	return "{\\autorefcite"+name+r"}\def\autorefcite"+name+r"{\textsuperscript{\ref{numref"+name+r"}}}"
replacer=lambda match: r"\unskip"+r"\textsuperscript{,}".join((singlereplacer(normalizecmdname(book)) for book in match.group(1).split(",")))
for in_line in sys.stdin:
	if in_line.startswith(r"\end{document}"):
		inside=False
	if not inside and not all_doc:		
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
	return re.sub(r"[\d\._:0-9-]","X",name)
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
		in_line = re.sub(r"\\bibitem{([^}]+)}",replacer,in_line)	
		if inside_def: 
			in_line = in_line.rstrip().replace(r"\BibEmph",r"\unskip\hspace{1mm}\BibEmph")
			
		sys.stdout.write(in_line)
endef
export PYMAKEAUTOREFBIB
autoref_params.tex:
	rm -f $@
	echo '\\def\\numberofdisserpages{124}' >> $@ 
autoref_bibcommands_generator.tex: Makefile autoref_bibcommands_generator.aux f5_references.bib gost/ugost2008s.bst
	rm -f autoref_bibcommands_generator.bbl
	bibtex autoref_bibcommands_generator.aux
	grep -v "thebibliography" < autoref_bibcommands_generator.bbl| python -c "$$PYMAKEAUTOREFBIB" >$@
auto_ref.pdf: autoref_bibcommands_generator.tex intro_for_autoref.tex auto_ref_plainrefs.tex autoref_params.tex Makefile
	python -c "$$PYMAKEAUTOREFCITES" --alldocument < auto_ref_plainrefs.tex >auto_ref_source.tex
	xelatex auto_ref_source.tex
	bibtex auto_ref_source.1.aux
	xelatex auto_ref_source.tex
	xelatex auto_ref_source.tex
	mv auto_ref_source.pdf auto_ref.pdf
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
origf5_termination_progr: origf5_termination_progr.tex origf5_termination_progr.pdf
origf5_termination_progr_final.tex: f5_example_run.tex origf5_termination_progr_pre.tex origf5_termination_progr.lyx Makefile
	iconv -t cp1251 < f5_example_run.tex > f5_example_run_1251.tex
	sed 's/inputencoding utf8/inputencoding cp1251/' < origf5_termination_progr.lyx > origf5_termination_progr_cp1251.lyx
	lyx -e pdflatex origf5_termination_progr_cp1251.lyx
	cat origf5_termination_progr_cp1251.tex | sed -n \
		-e '/input{f5_example_run.tex}/ r f5_example_run_1251.tex' -e '/input{f5_example_run.tex}/!p' \
		> origf5_termination_progr_cp1251_inc.tex
	rm -f origf5_termination_progr_cp1251_inc.bbl
	pdflatex origf5_termination_progr_cp1251_inc.tex
	mv -f origf5_termination_progr_cp1251_inc.aux origf5_termination_progr.aux
	bibtex origf5_termination_progr.aux
	iconv -t cp1251 < origf5_termination_progr.bbl | sed \
		-e 's/\\bbljan/January/'\
		-e 's/\\bblfeb/February/'\
		-e 's/\\bblapr/April/'\
		-e 's/\\bbljun/June/'\
		-e 's/\\bbljul/July/'\
		-e 's/\\bbldec/December/'\
		|grep -v "selectlanguage" |grep -v "expandafter"> origf5_termination_progr_cp1251.bbl
	cat origf5_termination_progr_cp1251_inc.tex | sed -n -e '/begin{document}/,$$p' | sed -n -e '0,/bibliographystyle/p'|head --lines=-1| LC_ALL=C sed \
		-e 's/flqq/guillemotleft/g'\
		-e 's/frqq/guillemotright/g'\
		-e 's/\\subsection/\\he/'\
		-e 's/\\section/\\He/'\
		-e 's/\\nameref.par./\\texttt\{/g'\
		-e 's/\\item \[\([^]]*\)\]/\\item [\\unskip\1\\hfil]/'\
		> origf5_termination_progr_document.tex
	(cat origf5_termination_progr_pre.tex origf5_termination_progr_document.tex origf5_termination_progr_cp1251.bbl; echo '\end{document}') | sed \
		-e 's/{thm}/{thmGOT}/'\
		-e 's/{lem}/{lemGOT}/'\
		-e 's/{cor}/{corGOT}/'\
		-e 's/{defn}/{defnGOT}/'\
		-e 's/{proof}/{proofGOT}/'\
		-e 's/\\HM/\\HMGOT/g'\
		-e 's/\\HC/\\HCGOT/g'\
		-e 's/{lyxlist}/{llistGOT}/'\
		>origf5_termination_progr_final.tex
origf5_termination_progr_final.pdf: origf5_termination_progr_final.tex Makefile
	rm -rf origf5_termination_progr_final
	mkdir origf5_termination_progr_final
	cp origf5_termination_progr_final.tex fancyhdr.sty  newprog1e.sty origf5_termination_progr_final/
	cd origf5_termination_progr_final; pdflatex origf5_termination_progr_final.tex
	cd origf5_termination_progr_final; pdflatex origf5_termination_progr_final.tex
	cp -f origf5_termination_progr_final/origf5_termination_progr_final.pdf .
