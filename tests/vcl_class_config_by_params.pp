# NOTE: don't run these tests on Production servers 
#

# setting up probes, backends, directors and selectors
# NOTE: it is recommened to use definitons for this,
#       check vcl_class_config_by_definitions.pp for examples 
#
#
# WARNING!!!
# commented lines provide old syntax style, 
# please make sure you don't use those
# they are left here only to show the diff
# between versions 0.x.x and 1.x.x syntax

class { 'varnish::vcl':

  probes => {
    'health_check1' => { url => '/health_check_url1' },
    'health_check2' => { 
      window    => '8',
      timeout   => '5s',
      threshold => '3',
      interval  => '5s',
      request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
    }
  },
#  probes => [
#    { name => 'health_check1', url => "/health_check_url1" },
#    { name      => 'health_check1',
#      window    => '8',
#      timeout   => '5s',
#      threshold => '3',
#      interval  => '5s',
#      request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ],
#    },
#  ],

  backends => { 
    'srv1' => { host => '172.16.0.1', port => '80', probe => 'health_check1' },
    'srv2' => { host => '172.16.0.2', port => '80', probe => 'health_check1' },
    'srv3' => { host => '172.16.0.3', port => '80', probe => 'health_check2' },
    'srv4' => { host => '172.16.0.4', port => '80', probe => 'health_check2' },
    'srv5' => { host => '172.16.0.5', port => '80', probe => 'health_check2' },
    'srv6' => { host => '172.16.0.6', port => '80', probe => 'health_check2' },
  }, 
#  backends => [
#    { name => 'srv1', host => '172.16.0.1', port => '80', probe => 'health_check_url1' },
#    { name => 'srv2', host => '172.16.0.2', port => '80', probe => 'health_check_url1' },
#    { name => 'srv3', host => '172.16.0.3', port => '80', probe => 'health_check_url2' },
#    { name => 'srv4', host => '172.16.0.4', port => '80', probe => 'health_check_url2' },
#    { name => 'srv5', host => '172.16.0.5', port => '80', probe => 'health_check_url2' },
#    { name => 'srv6', host => '172.16.0.6', port => '80', probe => 'health_check_url2' }
#  ],

  directors => {
    'cluster1' => { backends => [ 'srv1', 'srv2' ] },
    'cluster2' => { backends => [ 'srv3', 'srv4', 'srv5', 'srv6' ] }
  },
#  directors => [
#    {
#      name     => 'cluster1',
#      backends => [ 'srv1', 'srv2' ],
#     },
#    {
#      name     => 'cluster2',
#      backends => [ 'srv3', 'srv4' ],
#    },
#  ],

  selectors => {
    'cluster1' => { condition => 'req.url ~ "^/cluster1"' },
    'cluster2' => { condition => 'true' }
  }
#  selectors => [
#    { backend => 'cluster2', condition => 'req.url ~ "^/cluster2"' },
#    { backend => 'cluster1' },
#  ],
}
