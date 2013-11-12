# NOTE: don't run these tests on Production servers 
#

# simple setup
#
class { 'varnish::vcl': 
  probes => [
    { name => 'health_check', url => "/health_check" },
  ],
  backends => [
    { name => 'server1', host => '192.168.1.1', port => '80', probe => 'health_check' },
    { name => 'server2', host => '192.168.1.2', port => '80', probe => 'health_check' },
  ],
  directors => [
    { name => 'cluster', type => 'round-robin', backends => [ 'server1', 'server2' ] }
  ],
  selectors => [
    { backend => 'cluster' },
  ],
}

# slightly more complex setup
#
#class { 'varnish::vcl':
#  probes => [
#    {
#      name      => 'health_check1',
#      window    => '8',
#      timeout   => '5s',
#      threshold => '3',
#      interval  => '5s',
#      request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ],
#    },
#    {
#      name      => 'health_check2',
#      window    => '8',
#      timeout   => '5s',
#      threshold => '3',
#      interval  => '5s',
#      request   => [ "GET /action/healthCheck2 HTTP/1.1", "Host: www.example2.com", "Connection: close" ],
#    },
#  ],
#  backends => [
#    { name => 'server1', host => '192.168.1.21', port => '80', probe => 'health_check1' },
#    { name => 'server2', host => '192.168.1.22', port => '80', probe => 'health_check1' },
#    { name => 'server3', host => '192.168.1.23', port => '80', probe => 'health_check1' },
#    { name => 'server4', host => '192.168.1.24', port => '80', probe => 'health_check1' },
#    { name => 'server5', host => '192.168.1.25', port => '80', probe => 'health_check1' },
#    { name => 'server6', host => '192.168.1.26', port => '80', probe => 'health_check1' },
#    { name => 'server7', host => '192.168.1.27', port => '80', probe => 'health_check2' },
#    { name => 'server8', host => '192.168.1.28', port => '80', probe => 'health_check2' },
#  ],
#  directors => [
#    {
#      name     => 'cluster1',
#      backends => [ 'server1', 'server2', 'server3', 'server4', 'server5', 'server6' ],
#     },
#    {
#      name     => 'cluster2',
#      backends => [ 'server7', 'server8' ],
#    },
#  ],
#  selectors => [
#    { backend => 'cluster2', condition => 'req.url ~ "^/cluster2"' },
#    { backend => 'cluster1' },
#  ],
#}


