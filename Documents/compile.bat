pandoc -o %1.%2 %1.md --bibliography ..\Bib\masterBib.bib --csl ..\Bib\_apsr.csl --reference-%2 ..\reference.%2 %3
%1.%2
