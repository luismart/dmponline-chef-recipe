# Copyright (c) 2012  Cottage Labs
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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


