simple_sig_rus.pdf: simple_sig_rus.tex
	sed 's/\(\\usepackage\[unicode=true\]\|{hyperref}\)/% \0/' $^ > $^.modified
	mv -f $^.modified $^
	pdflatex $^
	pdflatex $^
view: simple_sig_rus.pdf
	rm simple_sig_rus.aux simple_sig_rus.log
	xdg-open $^
