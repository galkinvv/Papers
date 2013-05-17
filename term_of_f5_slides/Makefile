%.xetex.tex: %.lyx
	lyx -e xetex $^
	mv $$(python -c 'print "$@".replace(".xetex","")') $@

%.xetex.pdf: %.xetex.tex
	mkdir -p "/tmp/$^"
	#cp $^ *.cls "/tmp/$^"
	(cd /tmp/$^ && xelatex $^ && xelatex $^)
	mv /tmp/$^/$@ .
