SEDA-ML-vagrant-config
========================

In order to get started install the latest version of Vagrant from http://downloads.vagrantup.com/.

* If running vagrant on Windows make sure VM support is enabled in the BIOS. Google for machine specific virtualization enable instructions.

Run "git clone git@github.com:S-E-D-A/SEDA-ML-Summarization-vagrant-config.git".

From within this repository run "vagrant up" and after the steps have completed "vagrant ssh".
* If you get "precise64 box not found" run "vagrant box add precise64 http://files.vagrantup.com/precise64.box"

vagrant plugin install vagrant-cachier (For apt-get caching)

You are now ready to develop in the "source" folder.


