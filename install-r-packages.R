#!/usr/bin/env Rscript

#oldrepo <- "http://ftp.sunet.se/pub/lang/CRAN/"
# repo <- "http://cran.rstudio.com/" 
repo <- "http://ftp.acc.umu.se/mirror/CRAN/"
#update.packages(repos=repo, ask=FALSE)

packages <- c()
biocpackages <- c("CNAnorm", "QDNAseq", "QDNAseq.hg19")
githubrepos <- c("dakl/clinseqr")

for( package in packages ){ # package <- packages[1]
  if( !require(package = package, character.only = TRUE) ){
    install.packages(package, repos=repo)
  }
}

library(devtools)
for( repo in githubrepos ){ # repo <- githubrepos[1]
  package <- unlist(strsplit(x = repo, split = "/"))[2]
  if( !require(package = package, character.only = TRUE) ){
    install_github(repo)
  }
}

source("http://bioconductor.org/biocLite.R")
for( package in biocpackages ){ # package <- biocpackages[1]
  if( !require(package = package, character.only = TRUE) ){
    biocLite(package, suppressUpdates=TRUE)
  }
}

