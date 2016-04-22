pandoc -o %1.%2 %1.md --bibliography ..\..\Bib\masterBib.bib --csl ..\..\Bib\_apsr.csl --reference-%2 ..\..\reference.%2 --toc
echo Don't forget to add section page breaks, a title page and executive summary, and Table 1.
%1.%2
