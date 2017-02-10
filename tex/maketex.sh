#!/bin/bash

# trasforma un sito web statico in PDF

if [[ `basename \`pwd\`` != tex ]]; then
	echo "devi essere nella directory tex/ per invocare questo script"
	exit 1
fi

echo "\documentclass[a4paper]{article}" > sweki.tex
echo "\usepackage[T1]{fontenc}" >> sweki.tex
echo "\usepackage[utf8]{inputenc}" >> sweki.tex
echo "\usepackage[english,italian]{babel}" >> sweki.tex
echo "\usepackage{microtype}" >> sweki.tex
echo "\usepackage{booktabs}" >> sweki.tex
echo "\title{sweki}" >> sweki.tex
echo "\author{Giorgio Giuffrè}" >> sweki.tex
echo "\date{}" >> sweki.tex
echo "" >> sweki.tex
echo "\begin{document}" >> sweki.tex
echo "\maketitle" >> sweki.tex
echo "\tableofcontents" >> sweki.tex
echo "\newpage" >> sweki.tex

echo "Consultazione dell'indice html..."
xsltproc --html get_index.xsl ../index.html | grep html > _sweki_index

echo "trasformazione di XHTML in Latex..."
while read f; do
	f="../$f"
	name=`basename $f`
	name=${name%.*}
	./texents.sh $f > _sweki_entities_tmp
	xsltproc --html html_tex.xsl _sweki_entities_tmp > $name.tex
	rm -f _sweki_entities_tmp
	echo "\input{$name.tex}" >> sweki.tex
done < _sweki_index
rm -f _sweki_index
echo "\end{document}" >> sweki.tex

echo "generazione del documento PDF..."
# due invocazioni del comando, per riferimenti incrociati:
pdflatex -halt-on-error sweki.tex > _sweki_log rm -f _sweki_log && pdflatex -halt-on-error sweki.tex > _sweki_log && rm -f _sweki_log && echo "File generato"
rm -f *.log *.toc *.aux *.out *.tex # pulizia
