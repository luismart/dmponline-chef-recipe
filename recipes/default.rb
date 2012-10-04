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

# libxml-ruby needs devel
package 'libxml2-devel'
# libxslt-ruby needs devel
package 'libxslt-devel'

# Install nginx for reverse proxying
include_recipe 'nginx'

template '/etc/nginx/conf.d/default.conf' do
  action :create
  source 'nginx.conf.erb'
  notifies :reload, 'service[nginx]'
end

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

# Install and configure database server
include_recipe 'dmponline::database'

# Deploy DMPonline
deploy '/opt/dmponline' do
  deploy_to '/opt/dmponline'
  repo 'https://github.com/tjdett/DMPOnline.git'
  user 'dmponline'
  group 'dmponline'
  enable_submodules true
  environment 'RAILS_ENV' => 'production'
  shallow_clone true
  action :deploy # or :rollback
  restart_command 'echo implement restart'
  scm_provider Chef::Provider::Git
  symlink_before_migrate({
    'config/database.yml' => 'config/database.yml',
    'config/email.yml' => 'config/email.yml'
  })
  purge_before_symlink []
  create_dirs_before_symlink ['log', 'config']
  symlinks({'log' => 'log'})
  before_symlink do
    current_release = release_path

    rvm_shell 'bundle_install' do
      ruby_string '1.9.3'
      user        'dmponline'
      cwd         current_release
      code        <<-EOH
        ruby -v
        bundle install
      EOH
    end
  end
  before_restart do
    current_release = release_path
    shared_path = '/opt/dmponline/shared'

    directory "#{shared_path}/config"

    ['database', 'email'].each do |setting_type|
      template "#{shared_path}/config/#{setting_type}.yml" do
        action :create_if_missing
        source "#{setting_type}.yml.erb"
        user 'dmponline'
        group 'dmponline'
      end
    end

    rvm_shell 'migrate' do
      ruby_string '1.9.3'
      user        'dmponline'
      cwd         current_release
      code        <<-EOH
        rake db:migrate:status
        rake db:migrate
      EOH
    end
  end
end

