cv-proj-root := "../cv"
static-docs := "./static/docs"

up:
    hugo server --disableFastRender

update-cv:
    cp {{cv-proj-root}}/millman.bib {{static-docs}}/millman.bib
    cp {{cv-proj-root}}/cv.pdf {{static-docs}}/millman-cv.pdf
