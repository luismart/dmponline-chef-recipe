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
