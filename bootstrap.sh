#!/usr/bin/env bash
##
## This script must always be ran first when bringing up a vagrant box.
##
## Please keep in alphabetical order.
##

SOLR_BUILD=http://archive.apache.org/dist/lucene/solr/4.3.1/solr-4.3.1.tgz

# Bring apt-get up to date
apt-get update

# Git
apt-get install -y git

# Vim
apt-get install -y vim

# Create source directory
mkdir -p "/vagrant/source"

# Own as user
chown -R vagrant:vagrant "/vagrant/source/"

# Link source directory into home 
if [[ ! -L "/home/vagrant/source" ]]; then
  ln -s "/vagrant/source" "/home/vagrant/source"
fi

# Download Solr
wget ${SOLR_BUILD}
tar -zxvf solr-4.3.1.tgz
rm solr-4.3.1.tgz
cd solr-4.3.1
apt-get install -y openjdk-7-jdk
cd example
java -jar start.jar &
