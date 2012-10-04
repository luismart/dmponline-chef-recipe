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
# Recipe:: database

# Install MySQL server and client
include_recipe 'mysql::client'
include_recipe 'mysql::server'
include_recipe 'database::mysql'

mysql_connection_info = {
  :host => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

# Create MySQL database user
mysql_database_user 'dmponline' do
  connection mysql_connection_info
  password 'dmponline'
  action :create
end

['dmponline', 'dmponline_test'].each do |dbname|
  # Create MySQL database
  mysql_database dbname do
    connection mysql_connection_info
    action :create
  end

  # Grant privileges to user
  mysql_database_user 'dmponline' do
    connection mysql_connection_info
    database_name dbname
    action :grant
  end
end
