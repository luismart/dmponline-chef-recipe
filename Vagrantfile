# Before running vagrant, export the shell variable for the organization on Hosted Chef and
# make sure the validator certificate is in ~/.chef.
#
# export ORGNAME=dmponlineclchef
#
# Also be sure to export the shell variable for the vagrant box (linux flavor) you will be using
# See http://www.vagrantbox.es for a list of vagrant boxes
#
# This recipe is built with CentOS 6.3 x86_64 minimal
# https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box
#
# export VAGRANT_BOX=centos6
#
# You can optionally export a shell variable for your Chef server username if it is different
# from your OS user export OPSCODE_USER=bofh

#export ORGNAME=dmponlineclchef

node_name = "#{ENV['ORGNAME']}-vagrant-node"
base_box = ENV['VAGRANT_BOX'] || 'centos6'
 
Vagrant::Config.run do |config|
  config.vm.box = base_box
 
  config.vm.provision :chef_client do |chef|
 
    # Set up some organization specific values based on environment variable above.
    chef.chef_server_url = "https://api.opscode.com/organizations/#{ENV['ORGNAME']}"
    puts "#{ENV['HOME']}/.chef/#{ENV['ORGNAME']}-validator.pem"
    chef.validation_key_path = "#{ENV['HOME']}/.chef/#{ENV['ORGNAME']}-validator.pem"
    chef.validation_client_name = "#{ENV['ORGNAME']}-validator"
 
    # Change the node/client name for the Chef Server
    chef.node_name = node_name
 
    # Put the client.rb in /etc/chef so chef-client can be run w/o specifying
    chef.provisioning_path = "/etc/chef"
 
    # logging
    chef.log_level = :info
 
    # adjust the run list to suit your testing needs
    chef.run_list = ["recipe[dmponline]"]
  end
end