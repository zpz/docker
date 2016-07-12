#!/usr/bin/Rscript --vanilla

argv <- commandArgs(trailingOnly=TRUE)

if (is.null(argv) | length(argv) < 1) {
    cat("Usage: install.r pkg1 [pkg2 pkg3 ...]\n")
    q()
}

install.packages(argv,
                 contriburl="http://cran.rstudio.com/src/contrib/",
                 dependencies=c("Depends", "Imports"),
                 clean=TRUE, keep_outputs=FALSE)

