#
# Cookbook Name:: dmponline
# Recipe:: default
#

# Ensure we have Git installed for deployment
include_recipe 'git'

# Install MySQL server and client
include_recipe 'mysql::client'
include_recipe 'mysql::server'

# Install nginx for reverse proxying
include_recipe 'nginx'

# Configure iptables to allow SSH and HTTP
include_recipe 'iptables'
iptables_rule 'port_http'
iptables_rule 'port_ssh' do
  cookbook 'openssh'
end

# Create 'dmponline' user
user 'dmponline' do
  comment 'DMPOnline app server'
  home '/opt/dmponline'
  system true
  supports :manage_home => true
end

# Install RVM for 'dmponline'
# (Configured by attributes/default.rb)
include_recipe 'rvm::user'


