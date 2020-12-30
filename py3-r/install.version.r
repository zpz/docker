#!/usr/bin/Rscript --vanilla

argv <- commandArgs(trailingOnly=TRUE)

if (is.null(argv) | length(argv) < 2) {
    cat("Usage: install.version.r package version\n")
    q()
}

library(versions)

install.versions(argv[1], argv[2],
                 dependencies=c("Depends", "Imports"),
                 clean=TRUE, keep_outputs=FALSE)

