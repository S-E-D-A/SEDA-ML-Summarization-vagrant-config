#!/usr/bin/env bash
##
## This script has to be ran first when bringing up this vagrant configuration,
## sets up all essential libraries, dependencies and tools.
##

# To display detailed information when executing this script
# If SEDA_TS_VAGRANT_DEBUG_MODE
if [ ! -z ${SEDA_TS_VAGRANT_DEBUG_MODE} ]
then
    set -ex
fi

# The build of Solr to obtain
SOLR_VERSION=4.5.1
SOLR_BUILD_URL=http://mirror.tcpdiag.net/apache/lucene/solr
SOLR_BUILD_URL=${SOLR_BUILD_URL}/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz

####### apt-get ##########
# Variable to append Java apt-get install variables to
# PTI stands for PACKAGES TO INSTALL
PTI=''

# Java
PTI="${PTI} openjdk-7-jdk"

# Git
PTI="${PTI} git"

# Vim
PTI="${PTI} vim"

# Python packages and requirements
PTI="${PTI} curl zlib1g-dev libbz2-dev libreadline-dev libgdbm-dev libssl-dev \
libsqlite3-dev python python-setuptools python-dev python-numpy python-scipy python-matplotlib \
ipython ipython-notebook python-pandas python-sympy python-nose \
g++ python-software-properties libopenblas-base libopenblas-dev liblapack-dev \
gfortran libfreetype6-dev"

# Bring apt-get up to date
apt-get update

# Remove libatlas because Theanos requires blas, and it is faster
apt-get --purge -y remove libatlas3gf-base libatlas-dev

# Install all the apt-get packages
apt-get install -y ${PTI}

####### Python ##########  
   
# Upgrade older Ubuntu packages to most recent PyPi versions
# Sequence matters
easy_install pip
pip install --upgrade setuptools --no-use-wheel
pip install --upgrade pip
pip install --upgrade cython

# Install scimath and numpy, these components are at the bottom
# as they tend to cause problems and should crash at the end to avoid reprovisioning
pip install --upgrade numpy
/usr/local/bin/easy_install scimath
pip install --upgrade ipython[all] jinja2 vincent virtualenv pythonbrew pandas SciPy matplotlib
pip install --upgrade theano

# Switch symlink from libatlas to libopenblas
# Manually this would be done with commmand
# update-alternatives --config libblas.so.3gf < Option 2: /usr/lib/lapack/liblapack.so.3gf 
rm -rf /usr/lib/liblapack.so.3gf
ln -s /usr/lib/lapack/liblapack.so.3gf /usr/lib/liblapack.so.3gf

# Insert cludge to fix Theano imports
sed -i '130iimport numpy.distutils.__config__' /usr/local/lib/python2.7/dist-packages/theano/tensor/blas.py

####### Source directory #########

# Create source directory
mkdir -p "/vagrant/source"

# Link persistent source directory into home 
if [[ ! -L "/home/vagrant/source" ]]; then
  ln -s "/vagrant/source" "/home/vagrant/source"
fi

####### Solr install #########

# Create directory for solr in persistent folder
mkdir -p /home/vagrant/source/solr
# Go in it
cd /home/vagrant/source/solr
# Variable for Solr installed flag
DOT_SOLR_INSTALLED=/home/vagrant/source/solr/.solrinstalled

# Download Solr and install only if it's the first time provisioning
# indicated by whether or not .solrinstalled is present in / directory
if [ ! -f ${DOT_SOLR_INSTALLED} ]; then
  # Download
  wget ${SOLR_BUILD_URL}
  # Unzip
  tar -zxvf solr-${SOLR_VERSION}.tgz
  # Remove the compressed file
  rm solr-${SOLR_VERSION}.tgz
  # Write file to indicate Solr has been installed
  touch ${DOT_SOLR_INSTALLED}

  echo "Provisioning Solr."
else
  # Nothing needs to be done if /.solrinstalled is present
  echo "Solr already installed."
fi

###### Start Solr and IPython notebook #########

# Enter the Jetty jar server directory
cd /home/vagrant/source/solr/solr-${SOLR_VERSION}/example/

# Run Solr using the Jetty server
java -Xmx3012m -jar start.jar &

# Run IPython
ipython notebook --no-browser --ip=0.0.0.0 --notebook-dir=/home/vagrant/source --pylab=inline --script &
