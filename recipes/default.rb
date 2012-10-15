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

# Install sendmail for error reporting
package 'sendmail'
service 'sendmail' do
  action [:enable, :start]
end

# Create 'dmponline' user
user 'dmponline' do
  comment 'DMPOnline app server'
  home '/opt/dmponline'
  system true
  supports :manage_home => true
end

directory '/opt/dmponline' do
  mode 0755
end

# Install RVM for 'dmponline'
# (Configured by attributes/default.rb)
include_recipe 'rvm::user'

# Install and configure database server
include_recipe 'dmponline::database'

# Configure service (using bluepill)
include_recipe 'bluepill'
template '/etc/bluepill/dmponline.pill' do
  source 'dmponline.pill.erb'
end
bluepill_service 'dmponline' do
  action [:load, :enable]
end

# Install wkhtmltopdf
wkhtmltopdf_arch = case node['kernel']['machine']
when 'x86_64'
  'amd64'
else
  'i386'
end

remote_file '/tmp/wkhtmltopdf.tar.bz2' do
  source "http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.11.0_rc1-static-#{wkhtmltopdf_arch}.tar.bz2"
  not_if { File.exists?('/usr/local/bin/wkhtmltopdf') }
  notifies :run, 'bash[untar /tmp/wkhtmltopdf.tar.bz2]'
end

bash 'untar /tmp/wkhtmltopdf.tar.bz2' do
  action :nothing
  code <<-EOH
    cd /tmp
    yes | tar xjvf /tmp/wkhtmltopdf.tar.bz2
    cp /tmp/wkhtmltopdf-#{wkhtmltopdf_arch} /usr/local/bin/wkhtmltopdf
  EOH
  notifies :create, 'file[/usr/local/bin/wkhtmltopdf]'
end

file '/usr/local/bin/wkhtmltopdf' do
  action :nothing
  mode 0755
end

# wkhtmltopdf dependencies
%w[libXrender libXext].each {|p| package p }

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Generate 60 character secret token
node.set_unless['dmponline']['secret_token'] = (1..3).map{secure_password}.join

# Deploy DMPonline
deploy '/opt/dmponline' do
  deploy_to '/opt/dmponline'
  repo 'https://github.com/CottageLabs/DMPOnline.git'
  user 'dmponline'
  group 'dmponline'
  enable_submodules true
  environment 'RAILS_ENV' => 'production'
  shallow_clone true
  action :deploy # or :rollback
  restart_command do
    bluepill_service 'dmponline' do
      action [:load, :restart, :start]
    end
  end
  scm_provider Chef::Provider::Git
  symlink_before_migrate({
    'config/database.yml' => 'config/database.yml',
    'config/email.yml' => 'config/email.yml',
    'config/secret_token.rb' => 'config/initializers/secret_token.rb'
  })
  #purge_before_symlink %w[log tmp/pids]
  #create_dirs_before_symlink %w[]
  before_symlink do
    current_release = release_path
    shared_path = '/opt/dmponline/shared'

    %w[log tmp/pids].each do |d|
      directory "#{current_release}/#{d}" do
        action :delete
      end
    end

    %w[config log pids].each do |d|
      directory "#{shared_path}/#{d}" do
        user 'dmponline'
        group 'dmponline'
      end
    end

    %w[database.yml email.yml secret_token.rb unicorn.rb].each do |config_file|
      template "#{shared_path}/config/#{config_file}" do
        action :create_if_missing
        source "#{config_file}.erb"
        user 'dmponline'
        group 'dmponline'
      end
    end

    rvm_shell 'bundle_install' do
      ruby_string '1.9.3'
      user        'dmponline'
      cwd         current_release
      code        <<-EOH
        ruby -v
        bundle install
      EOH
    end

    rvm_shell 'setup' do
      ruby_string '1.9.3'
      user        'dmponline'
      cwd         current_release
      code        <<-EOH
        rake db:setup
      EOH
      not_if { File.exists?("#{shared_path}/db_installed") }
    end

    file "#{shared_path}/db_installed" do
      action :touch
    end

  end
  symlinks({'log' => 'log', 'pids' => 'tmp/pids'})
  before_restart do
    current_release = release_path

    rvm_shell 'migrate' do
      ruby_string '1.9.3'
      user        'dmponline'
      cwd         current_release
      code        <<-EOH
        rake db:migrate
        rake assets:clean
        rake assets:precompile
      EOH
    end

    file "#{current_release}/tmp/restart.txt" do
      action :touch
      user  'dmponline'
      group 'dmponline'
    end

  end
end
