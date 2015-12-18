# vim: set et ft=gnuplot sw=4 :

set terminal tikz color size 4.3in,4.5in font '\scriptsize'
set output "graph-reduced.tex"

set datafile separator ","

set multiplot

set border 3
set nokey
set xlabel "Runtime (ms)"
set ylabel "Cumulative Number of Instances Solved"
set logscale x
set xtics nomirror
set ytics nomirror add (2336)
set ytics scale 1,0.01
set mytics 5
set grid xtics ytics mytics
set xrange [1:1e8]
set yrange [0:2336]
set format x '$10^{%T}$'

set arrow from 2277e3, 1800 to screen 0.72, screen 0.70 lw 1 front filled

set arrow from 1e4,1800 to 1e8,1800 front nohead
set arrow from 1e4,2336 to 1e8,2336 front nohead
set arrow from 1e4,1800 to 1e4,2336 front nohead
set arrow from 1e8,1800 to 1e8,2336 front nohead

plot \
    "no-presolved-presolver.csv" u (strcol(2) eq "lad" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 1 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "supplementallad" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 2 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "vf2" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 4 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow1" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 5 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow2" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 6, \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow3" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 7 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow4" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 3 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "virtual.best.lad" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 8 dt "-", \
    "no-presolved-presolver.csv" u (strcol(2) eq "portfolio" ? $3 : NaN):($3 >= 1e8 ? 1e-10 : 1) smooth cumulative with steps notitle lc 8 lw 2

set size 0.38, 0.5
set origin 0.53, 0.20
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
unset arrow
set border 15
clear

set nokey
set noytics
set xrange [1e4:1e8]
set xtics scale 0 format ""
set y2tics scale 0.01,0.01 format ""
set y2range [1800:2336]
set y2tics mirror
set y2tics 1000
set my2tics 5
set xlabel ""
set ylabel ""
set grid xtics y2tics mytics my2tics

plot \
    "no-presolved-presolver.csv" u (strcol(2) eq "lad" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps notitle lc 1 dt ".", \
    "no-presolved-presolver.csv" u (strcol(2) eq "supplementallad" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps notitle dt "." lc 2, \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow1" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps notitle dt "." lc 5, \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow2" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps ti '\raisebox{0mm}{\GlasgowTwoNS{}}' at end lc 6, \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow3" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps notitle dt "." lc 7, \
    "no-presolved-presolver.csv" u (strcol(2) eq "glasgow4" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps notitle dt "." lc 3, \
    "no-presolved-presolver.csv" u (strcol(2) eq "virtual.best.lad" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps ti '\raisebox{1mm}{VBS}' at end lc 8 dt "-", \
    "no-presolved-presolver.csv" u (strcol(2) eq "portfolio" ? ($3<1e4?1e4:$3) : NaN):($3 >= 1e8 ? 1e-10 : 1) axes x1y2 smooth cumulative with steps ti '\raisebox{0mm}{\LLAMANS}' at end lc 8 lw 2

unset multiplot
