#!/bin/bash

# conda
wget http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
bash Miniconda-latest-Linux-x86_64.sh -b -p /nfs/PROBIO/miniconda2

conda config --add channels r
conda config --add channels bioconda

pip install --upgrade pydotplus
pip install --upgrade vcf_parser
pip install --upgrade supervisor
pip install --upgrade pybedtools

mkdir -p /nfs/PROBIO/logs

# install psycopg2 and cryptography using conda
# they are needed for referral-manager, but fail to install using pip
conda install -y psycopg2 cryptography

# pip install from github/clinseq
pip install git+https://github.com/ClinSeq/referral-manager.git
pip install git+https://github.com/clinseq/localq.git
pip install git+https://github.com/clinseq/multiqc-alascca.git
pip install git+https://github.com/clinseq/pypedream.git
pip install git+https://github.com/clinseq/reportgen.git

# Create a separate environment for svcaller, as it's python 3:
conda create -y --name svcallerenv python=3.6
source activate svcallerenv
pip install git+https://github.com/tomwhi/svcaller.git
source deactivate

function git_clone_or_pull {
    if cd $2 ; then
      git pull
      cd ..
    else
      git clone $1 $2;
    fi
}

git_clone_or_pull https://github.com/clinseq/autoseq.git /nfs/PROBIO/autoseq
git_clone_or_pull https://github.com/clinseq/autoseq-scripts.git /nfs/PROBIO/autoseq-scripts

pip install -r /nfs/PROBIO/autoseq-scripts/requirements.txt

conda install -y --file /nfs/PROBIO/autoseq/conda-list-tests.txt
conda install -y --file /nfs/PROBIO/autoseq/conda-list.txt
pip install  /nfs/ALASCCA/autoseq

# Create a separate environment for qdnaseq, due to conflicts with R versions:
# conda create -y --name qdnaseqenv
# source activate qdnaseqenv
# conda install -y r=3.3.1
# conda install -y r-data.table=1.10.0
# conda install -y r-getopt=1.20.0
# conda install -y bioconductor-qdnaseq=1.10.0
# source deactivate

# build number 6 (latest as of Dev 7 2016) of bioperl is only 5.7 kb an is missing various modules, install build number 4 manually
# this issue can be followed at https://github.com/bioconda/bioconda-recipes/issues/3131
# wget https://anaconda.org/bioconda/perl-bioperl/1.6.924/download/linux-64/perl-bioperl-1.6.924-4.tar.bz2
# conda install perl-bioperl-1.6.924-4.tar.bz2

conda install -y -c bioconda perl-bioperl

## TexLive 2015
cd /tmp
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -zxvf install-tl-unx.tar.gz
cd install-tl-*
./install-tl -profile /nfs/ALASCCA/alascca-dotfiles/texlive.profile

# Clone mSINGS and set up it's virtual environment
conda install -y virtualenv  # required for msings vir env setup
git_clone_or_pull https://bitbucket.org/uwlabmed/msings.git /nfs/ALASCCA/msings
cd /nfs/PROBIO/msings/
bash dev/bootstrap.sh  # setting up the vir env and installing msings within it
cd ..

# Install PureCN and dependencies in a conda environment
conda create -y --name purecn-env R=3.4.1 r-xml
source activate purecn-env
R --vanilla --quiet -e 'source("https://bioconductor.org/biocLite.R")' \
-e 'biocLite("PureCN")' \
-e 'biocLite("TxDb.Hsapiens.UCSC.hg19.knownGene")' \
-e 'biocLite("org.Hs.eg.db")' \
-e 'install.packages("optparse", repos = "http://ftp.acc.umu.se/mirror/CRAN/")'
source deactivate


######################################################
# at this point, integration tests can be run with the installed verion of autoseq, like so:
# cd /nfs/ALASCCA/autoseq
# python tests/run-integration-tests.py
######################################################

######################################################
# install autoseq web API (autoseq-api) and front-end (aurora)
# needs pwd

git_clone_or_pull https://bitbucket.org/clinseq/aurora.git /nfs/ALASCCA/aurora
git_clone_or_pull https://bitbucket.org/clinseq/autoseqapi.git /nfs/ALASCCA/autoseq-api
git_clone_or_pull https://bitbucket.org/clinseq/clinseq-info /nfs/ALASCCA/clinseq-info
git_clone_or_pull https://bitbucket.org/clinseq/genome-resources /nfs/ALASCCA/genome-resources


pip install -r /nfs/ALASCCA/autoseq-api/requirements.txt
pip install -e /nfs/ALASCCA/autoseq-api

pip install -r /nfs/ALASCCA/aurora/requirements.txt
pip install -e /nfs/ALASCCA/aurora

echo
echo "you should now run "
echo generate-ref --genome-resources /nfs/ALASCCA/genome-resources --outdir /nfs/ALASCCA/autoseq-genome
echo "to generate reference files required by autoseq"
echo
