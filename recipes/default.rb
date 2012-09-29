#
# Cookbook Name:: dmponline
# Recipe:: default
#

# Ensure we have Git installed for deployment
include_recipe "git"

# Install MySQL server and client
include_recipe "mysql::client"
include_recipe "mysql::server"

# Install nginx for reverse proxying
include_recipe "nginx"


