simple_sig_rus.vestnik.tex: simple_sig_rus.tex
	sed\
		-e 's/\\label{eq:gvw-order-3}/\\tag{1}/'\
		-e 's/\\eqref{eq:gvw-order-3}/(1)/'\
		-e 's/\\label{eq:left-or-right-monom}/\\tag{2}/'\
		-e 's/\\eqref{eq:left-or-right-monom}/(2)/'\
		-e 's/\\vestnikonly}\[1\]{}/\\vestnikonly}[1]{#1}/'\
		-e 's/\\novestnikonly}\[1\]{#1}/\\novestnikonly}[1]{}/'\
		-e 's/\(\\usepackage\[unicode=true\]\|{hyperref}\)/% \0/'\
		$^ > $@
simple_sig.tex: simple_sig_rus.tex
	sed\
		-e 's/documentclass\[russian\]/documentclass\[english\]/'\
		-e 's/\\providecommand{\\[[:alpha:]]*}{\\inputencoding{koi8-r}/% \0/'\
		$^ > $@
simple_sig_rus.vestnik.pdf: simple_sig_rus.vestnik.tex
	pdflatex $^
	pdflatex $^
simple_sig_rus.pdf: simple_sig_rus.tex
	pdflatex $^
	bibtex simple_sig_rus.aux
	pdflatex $^
simple_sig.pdf: simple_sig.tex
	pdflatex $^
	bibtex simple_sig.aux
	pdflatex $^
clean-logs:
	rm -f *.aux *.log *.out
view-vestnik: simple_sig_rus.vestnik.pdf
	make clean-logs
	xdg-open $^
view-rus: simple_sig_rus.pdf
	make clean-logs
	xdg-open $^
view: simple_sig.pdf
	make clean-logs
	xdg-open $^

