all : tables graphs
	latexmk -pdf -pdflatex='pdflatex -interaction=nonstopmode %O %S' paper

TABLES =

GRAPHS = graph-cumulative.tex

tables : $(TABLES)

graphs : $(GRAPHS)

graph-%.tex : graph-%.gnuplot
	gnuplot $<

