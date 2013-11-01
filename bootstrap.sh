#!/usr/bin/env bash
##
## This script must always be ran first when bringing up a vagrant box.
##
## Please keep in alphabetical order.
##

# The build of Solr to obtain
SOLR_BUILD=http://archive.apache.org/dist/lucene/solr/4.3.1/solr-4.3.1.tgz

# Bring apt-get up to date
apt-get update

# Install Java
apt-get install -y openjdk-7-jdk

# Git
apt-get install -y git

# Vim
apt-get install -y vim

# Create source directory
mkdir -p "/vagrant/source"

# Own source directory as user
chown -R vagrant:vagrant "/vagrant/source/"

# Link persistent source directory into home 
if [[ ! -L "/home/vagrant/source" ]]; then
  ln -s "/vagrant/source" "/home/vagrant/source"
fi

# Download Solr and install only if it's the first time provisioning
# indicated by whether or not .solrinstalled is present in / directory
if [ ! -f /.solrinstalled ]; then
  # Download
  wget ${SOLR_BUILD}
  # Unzip
  tar -zxvf solr-4.3.1.tgz
  # Remove the compressed file
  rm solr-4.3.1.tgz
  # Write file to indicate Solr has been installed
  touch /.solrinstalled

  echo "Provisioning Solr."
else
  # Nothing needs to be done if /.solrinstalled is present
  echo "Solr already installed."
fi

# Enter the Jetty jar server directory
cd solr-4.3.1/example
# Run Solr using the Jetty server
java -jar start.jar &

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
