# -*- mode: ruby -*-
site :opscode

{
  'pkg-build' => 'develop',
  'repository' => 'develop',
  'fpm-tng' => 'develop',
  'lxc' => 'develop',
  'builder' => 'master',
  'gpg' => 'master'
}.each do |cb, branch|
  # cookbook cb, github: "hw-cookbooks/#{cb}", branch: branch
end

upstream_cookbooks = [
].each do |up_cb|
  cookbook up_cb
end

current_dir = File.dirname(__FILE__)
site_cookbooks = File.join(current_dir, "site-cookbooks")

local_cookbooks = Dir[File.join(site_cookbooks,'*','metadata.rb')].map do |cookbook_metadata|
  File.dirname(cookbook_metadata).split(File::SEPARATOR).last
end.each do |cookbook|
  cookbook cookbook, path: File.expand_path(File.join(site_cookbooks, cookbook))
end
