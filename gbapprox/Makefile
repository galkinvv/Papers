%.xetex.tex: %.lyx
	lyx -e xetex $^
	mv $$(python -c 'print "$@".replace(".xetex","")') $@

%.xetex.pdf: %.xetex.tex
	mkdir -p "/tmp/$^"
	cp $^ "/tmp/$^"
	(cd "/tmp/$^" && xelatex $^ ) && bibtex /tmp/$^/*.aux && (cd /tmp/$^ && xelatex $^ && xelatex $^)
	mv /tmp/$^/$@ .
