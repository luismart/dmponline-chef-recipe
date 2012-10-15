Description
===========

A chef cookbook for installing DMPonline.

Requirements
============

See `metadata.rb` for cookbook dependencies. If you're using
[Chef Librarian][librarian] then they should be installed automatically except
for `rvm`, which is not the community version:

```ruby
cookbook 'rvm', :git => 'https://github.com/fnichol/chef-rvm'
```

Attributes
==========

*Coming soon*

Usage
=====

Just include the default recipe in your run list: `recipe[dmponline]`

[librarian]: https://github.com/applicationsonline/librarian


Installing DMPOnline on a VirtualBox machine using Vagrant
==========================================================

[Vagrant](http://vagrantup.com) is a tool for programmatically managing [Virtual Box](http://www.virtualbox.org). It is able to (amongst other things) deploy new virtualised environments and provision them with Chef cookbooks. 

0. Requirements
---------------
You will need a system with a modern Ruby on Rails, Gem and Chef installed. Chef can be installed with:

 ```$ gem install chef```

1. Install Oracle Virtual Box
-----------------------------
Virtual Box is available for most platforms from [www.virtualbox.org](http://www.virtualbox.org). Download and install the latest version of Virtual Box, plus the extension pack. These instructions were prepared using Virtual Box 4.2.1 for OS X.

2. Install Vagrant
------------------
Vagrant is available for most platforms from [vagrantup.com](http://vagrantup.com). Download and install the latest version of Vagrant. These instructions were prepared using Vagrant 1.0.5

3. Download a suitable base machine
-----------------------------------
 Most versions of Linux/Unix-like operating systems should be OK to run DMPOnline. These instructions were prepared using a CentOS 6.3 x86_64 minimal box as a base machine. See [www.vagrantbox.es](http://www.vagrantbox.es) for a list of base boxes.

 Once a box has been selected, install it with the vagrant command

 ```$ vagrant box add centos6 https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box```

4. Configure your Hosted Chef key
---------------------------------
You will need your ORGNAME-validator.pem key file located in ~/.chef/ folder.
Export the ORGNAME variable with your organisation name:

 ```$ export ORGNAME=dmponlineclchef```

5. Run the cookbook
-------------------
 ```$ vagrant up```

 This command will initialise the virtual machine and then provision it for DMPOnline. It will take some time (30-60 minutes) to provision.


