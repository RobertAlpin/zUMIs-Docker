
##quay.io for some interesting containers
##Make this an app? Need to incorporate input files.

## Xenial  w/ samtools
FROM quay.io/biocontainers/samtools:1.7--2
 
##Set up filesystem (auto-bindpoints in ocelote, depend)
RUN mkdir /extra /rsgrps /cm /cm/shared /xdisk \
&&  mkdir /depend /zUMIs

WORKDIR /depend/
##Basic Ubuntu utilities for installation
RUN apt-get update \
&& apt-get install -y make apt-transport-https wget gcc unzip software-properties-common git\
&& apt-get install -y libcurl4-openssl-dev libpng-dev libxslt-dev libssl-dev libxml2-dev xsltproc

##Get R
RUN pt-key adv --recv-keys --keyserver keyserver.ubuntu.com 51716619E084DAB9 \
   && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" \
   && add-apt-repository main \
   && add-apt-repository universe \
   && apt-get update \
   && apt-get update \
   && apt-get install -y r-base
  
##Get Rscript, install packages
COPY zUMIs_R_Dependancies.R /depend/
RUN Rscript zUMIs_R_Dependancies.R

## Get more specific utilities
#pigz
WORKDIR /depend/
RUN   wget https://zlib.net/pigz/pigz-2.4.tar.gz \
&& tar xzf pigz-2.4.tar.gz \
&& cd pigz-2.4 \
&& make \
&& mv pigz /bin/ 

#samtools is taken care of btw

#STAR (2.5.4b)
WORKDIR /depend/
RUN    wget https://github.com/alexdobin/STAR/archive/2.5.4b.tar.gz \
   && tar -xzf 2.5.4b.tar.gz \
   && cd STAR-2.5.4b \
   && cd bin \
   && cd Linux_x86_64 \
   && mv STAR STARlong /bin/
   
## Get zUMIs proper
WORKDIR /zUMIs/
RUN git clone https://github.com/sdparekh/zUMIs.git


ENTRYPOINT BASH /zUMIs/zUMIs-master.sh -s STAR -t samtools -p pigz -r Rscript -d /zUMIs/zUMIs-master/
#From here, -y /path/to/input/[example].yaml 
