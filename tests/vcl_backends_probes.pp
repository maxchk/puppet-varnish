# NOTE: don't run these tests on Production servers
#

# if you are/were using 0.x.x syntax, please check file vcl_class_config_by_params.pp
# to see the diff between syntax for versions 0.x.x and 1.x.x
#
class { 'varnish::vcl': }

# configure probes
varnish::probe { 'health_check1': url => '/health_check_url1' }
varnish::probe { 'health_check2':
      window    => '8',
      timeout   => '5s',
      threshold => '3',
      interval  => '5s',
      request   => [ "GET /healthCheck2 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
}

# configure backends
varnish::backend { 'srv1': host => '172.16.0.1', port => '80', probe => 'health_check1' }
varnish::backend { 'srv2': host => '172.16.0.2', port => '80', probe => 'health_check2' }
 
# configure selectors
varnish::selector { 'srv1': condition => 'req.url ~ "^/url_on_srv1"' }
varnish::selector { 'srv2': condition => 'true' } # will be used as default by Varnish
