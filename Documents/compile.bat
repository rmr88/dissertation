pandoc -o %1.%2 %1.md --bibliography ..\Bib\masterBib.bib --csl ..\Bib\vancouver.csl --reference-%2 ..\template_duke_university_dissertation_docx.%2 %3
%1.%2
