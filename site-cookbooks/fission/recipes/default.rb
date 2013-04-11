#
# Cookbook Name:: fission
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

node.default['omnibus_updater']['version'] = nil
node.default['omnibus_updater']['version_search'] = true

include_recipe "omnibus_updater"
include_recipe "git"
include_recipe "ubuntu"
include_recipe "apt"

node.default['ruby_installer']['package_name'] = "ruby1.9.3"
node.default['ruby_installer']['rubygem_package'] = false
node.default['ruby_installer']['rubydev_package'] = "ruby1.9.1-dev"

include_recipe "ruby_installer"

gem_package "bundler"
