# Getting started with local fission development

This document outlines the basic steps necessary for starting work with fission-related projects.  The testing/development workflow modeled here will utilize a virtual machine setup to run services within the fission pipeline project.

1. Prerequisites for running VM
  * Download/install virtualbox https://www.virtualbox.org/wiki/Downloads
  * Download/install vagrant    https://www.vagrantup.com/downloads.html
  * Download/load ubuntu box    http://files.vagrantup.com/precise64.box
    * `vagrant box add --name precise64 precise64.box`
2. Preparing VM environment
  * create necessary dir structure: `mkdir -p hw/fission`
  * in hw/: `git clone git@github.com:hw-product/fission-vagrant-testing.git`
  * clone fission repos (from hw/fission-vagrant-testing):
    * `bin/clone-repos`
3. Starting / configuring VM
....
