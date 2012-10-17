Description
===========

A chef cookbook for installing DMPonline.

How to use this cookbook
========================

See the [dmponline-chef-repo](https://github.com/CottageLabs/dmponline-chef-repo) project for full installation instructions.



How to use this cookbook in other recipes
=========================================

Just include the default recipe in your run list: `recipe[dmponline]`

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

[librarian]: https://github.com/applicationsonline/librarian
