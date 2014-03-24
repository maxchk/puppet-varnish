# NOTE: don't run these tests on Production servers
#

# if you are/were using 0.x.x syntax, please check file vcl_class_config_by_params.pp
# to see the diff between syntax for versions 0.x.x and 1.x.x
#
class { 'varnish::vcl':
  backends => {}, # without this line you will not be able to redefine backend 'default'
}

# configure single backend, named 'default'
varnish::backend { 'default': host => '172.16.0.1', port => '80' }
