# Getting started with local fission development

This document outlines the basic steps necessary for starting work with fission-related projects.  The testing/development workflow modeled here will utilize a virtual machine setup to run services within the fission pipeline project.

1. Prerequisites for running VM
  * Download/install virtualbox (https://www.virtualbox.org/wiki/Downloads)
  * Download/install vagrant    (https://www.vagrantup.com/downloads.html)
  * Download/load ubuntu box    (http://files.vagrantup.com/precise64.box)
    * `vagrant box add --name precise64 precise64.box`

2. Preparing VM environment
  * create necessary dir structure: `mkdir -p hw/fission`
  * in hw/: `git clone git@github.com:hw-product/fission-vagrant-testing.git`
  * in hw/fission-vagrant-testing: `bundle && bundle exec librarian-chef install`
  * clone fission repos (from hw/fission-vagrant-testing):
    * `bin/clone-repos`

3. Starting / configuring VM
  * Start VM from hw/fission-vagrant-testing dir `INITIAL=true vagrant up`
  * ssh into new machine `vagrant ssh`
  * su to root `sudo su`
  * install updates `apt-get update && apt-get upgrade`
  * Install prereqs for rbenv / ruby-build:
    * `apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev git`
  * Install postgres 9.3 (http://www.postgresql.org/download/linux/ubuntu/)
  * After main install, ensure you grab the postgresql 9.3 dev libs (necessary header files for pg gem): `apt-get install postgresql-server-dev-9.3`
  * Update /etc/postgresql/9.3/main/pg_hba.conf to use md5 for local connections and restart postgres
  * Create fission user (with pw: fission-password): `su -c 'createuser -d -P fission' postgres`
  * Create fission db `createdb -U fission fission`

4. Create dev user to run ruby, fission, etc
  * `groupadd dev`
  * `useradd -g dev -m -s /bin/bash dev`
  * Restart VM (necessary to have /fission owned by dev)
    * exit out of current vagrant ssh session
    * `INITIAL=true vagrant halt`
    * `vagrant up`
    * scp your ssh private key (for interacting with heavywater github) into dev's .ssh/ (get the relevant ssh info from `vagrant ssh-config`)
    * ssh into vagrant and prep said key (as root) eg:
      * `mv /home/vagrant/foo.pem /home/dev/.ssh/`
      * `chown dev /home/dev/.ssh/foo.pem`
      * `chmod 600 /home/dev/.ssh/foo.pem`
    * load ssh-agent / key (as dev user)
      * `echo '[ ! $(pgrep ssh-agent) ] && eval $(ssh-agent) && ssh-add ~/.ssh/foo.pem' >> .bashrc`
      * `bash`

5. Setup Ruby (as dev user)
  * clone rbenv `git clone https://github.com/sstephenson/rbenv.git ~/.rbenv`
  * and ruby-build `git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build`
  * initialize!
    * `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
    * `echo 'eval "$(rbenv init -)"' >> ~/.bashrc`
    * `bash`
  * install/use latest 2.x ruby
    * `RB_V=$(rbenv install --list | grep -P '^\s*2\.\d\.\d\s*$' | tail -1)`
    * `rbenv install $RB_V`
    * `rbenv global $RB_V --default`
    * oblig: `gem install bundler && rbenv rehash`
    * finally!!!  `cd /fission/fission && FISSION_LOCALS=true bundle`
