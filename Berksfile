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
  cookbook cb, github: "hw-cookbooks/#{cb}", branch: branch
end

current_dir = File.dirname(__FILE__)
site_cookbooks = File.join(current_dir, "site-cookbooks")

Dir[File.join(site_cookbooks,'*','metadata.rb')].each do |cookbook_metadata|
  cb = File.dirname(cookbook_metadata).split(File::SEPARATOR).last
  cookbook cb, path: File.expand_path(File.join(site_cookbooks, cb))
end
