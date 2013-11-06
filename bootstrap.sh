#!/usr/bin/env bash
##
## This script has to be ran first when bringing up this vagrant configuration,
## sets up all essential libraries, dependencies and tools.
##

# To display detailed information when executing this script
set -ex

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
python-pip g++ python-software-properties libopenblas-base libopenblas-dev liblapack-dev \
gfortran libfreetype6-dev"

# Bring apt-get up to date
apt-get update

# Remove libatlas because Theanos requires blas, and it is faster
apt-get --purge -y remove libatlas3gf-base libatlas-dev

# Switch symlink from libatlas to libopenblas
# Manually this would be done with commmand
# update-alternatives --config libblas.so.3gf < Option 2: /usr/lib/lapack/liblapack.so.3gf 
rm -rf /usr/lib/liblapack.so.3gf
ln -s /usr/lib/lapack/liblapack.so.3gf /usr/lib/liblapack.so.3gf

# Install all the apt-get packages
apt-get install -y ${PTI}
 
####### Python ##########  
   
# Upgrade older Ubuntu packages to most recent PyPi versions
# Sequence matters
pip install distribute --upgrade
pip install ipython[all] numpy jinja2 vincent virtualenv pythonbrew pandas scimath SciPy matplotlib  --upgrade
pip install theano --upgrade

# Insert cludge to fix Theano imports
sed -i '134iimport numpy.distutils.__config__' /usr/local/lib/python2.7/dist-packages/theano/tensor/blas.py 

####### Source directory #########

# Create source directory
mkdir -p "/vagrant/source"

# Link persistent source directory into home 
if [[ ! -L "/home/vagrant/source" ]]; then
  ln -s "/vagrant/source" "/home/vagrant/source"
fi

####### Solr install #########

# Download Solr and install only if it's the first time provisioning
# indicated by whether or not .solrinstalled is present in / directory
if [ ! -f /.solrinstalled ]; then
  # Download
  wget ${SOLR_BUILD_URL}
  # Unzip
  tar -zxvf solr-${SOLR_VERSION}.tgz
  # Remove the compressed file
  rm solr-${SOLR_VERSION}.tgz
  # Write file to indicate Solr has been installed
  touch /.solrinstalled

  echo "Provisioning Solr."
else
  # Nothing needs to be done if /.solrinstalled is present
  echo "Solr already installed."
fi

###### Start Solr and IPython notebook #########

# Enter the Jetty jar server directory
cd /home/vagrant/
cd /home/vagrant/solr-${SOLR_VERSION}/example/

# Run Solr using the Jetty server
java -jar start.jar &

<<<<<<< HEAD
# Run IPython
ipython notebook --no-browser --ip=0.0.0.0 --notebook-dir=/home/vagrant/source &
=======
# Python
apt-get install -y curl
apt-get install -y zlib1g-dev libbz2-dev libreadline-dev libgdbm-dev libssl-dev libsqlite3-dev
apt-get install -y python python-setuptools python-dev
apt-get install -y python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose
apt-get install -y python-software-properties

easy_install pip

pip install ipython[all]
pip install jinja2
pip install vincent
pip install virtualenv
pip install pythonbrew
pip install pandas
pip install matplotlib
pip install IPython
pip install SciPy
pip install theano

# Run IPython
sudo -u vagrant ipython notebook --no-browser --ip=0.0.0.0 --notebook-dir=/home/vagrant/source &
>>>>>>> 5d713e78b29dcf2eefe9c0e9f8bd60559978b6a3
