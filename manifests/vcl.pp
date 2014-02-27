# == Class: varnish::vcl
#
# to change name/location of vcl file, use $varnish_vcl_conf in the main varnish class
#
# === Parameters
#
# probes     - list of probes to configure, must be an array of hashes:
#              [
#                { name => 'probe1', url = '/healthcheck1' },
#                { name => 'probe2', url = '/healthcheck2' },
#              ]
#              after 'name' you can provide any Varnish .probe parameters
#              just drop the . and use key => val syntax:
#              timeout => '5s', window => '8', and so on
#
# backends   - list of backends to configure, must be an array of hashes
#              [
#                { name => 'srv1', host => '10.0.0.1', port => '80' },
#                { name => 'srv2', host => '10.0.0.2', port => '80' },
#              ]
#              after 'name' you can provide any Varnish .backend parameters in the same way as for probes
#
# directors  - list of directors to configure, must be an array of hashes
#              [
#                { name => 'director1', type => 'round-robin', backends => [ 'srv1', 'srv2' ] },
#                { name => 'director2', type => 'round-robin', backends => [ 'srv3', 'srv4' ] },
#              ]
#
# acls       - list of acls to configure, must be an array of hashes
#              [
#                { name => 'acl1', hosts => [ '"localhost"', '"10.0.0.0"/24', '! "10.0.0.1"' ] },
#                { name => 'acl2', hosts => [ '"localhost"', '"10.1.0.0"/24', '! "10.1.0.1"' ] },
#              ]
#
# selectors  - list of selectors, configured only when multiple backends/directors are in use, must be an array
#              will be configured in the same order as listed in manifest
#
# conditions - list of conditions to apply, must be an array of hashes
#
# template   - you can build your own template and pass it to thei class with option template
#              please make sure your template uses same vars and datatypes as original one
#
#
# NOTE: VCL applies following restictions:
# - if you define a probe it must be used
# - if you define a backend it must be used
# - if you define a director it must be used
#
# You cannot define 2 or more backends/directors and not to have selectors
# Not following above rules will result in VCL compilation failure
#
#
# === Examples
#
# configure a single backend, ip address 192.168.1.1, port 80, no probe
# class {'varnish::vcl':
#   backends => [
#     { name => 'server1', host => '192.168.1.1', port => '80' },
#   ]
# }
#
# configure probe 'health_check', 2 backends using that probe and 1 director using 2 backends
# class {'varnish::vcl':
#   probes => [
#     { name => 'health_check', url => "/health_check" },
#   ],
#   backends => [
#     { name => 'server1', host => '192.168.1.1', port => '80', probe => 'health_check' },
#     { name => 'server2', host => '192.168.1.2', port => '80', probe => 'health_check' },
#   ],
#  directors => [
#    { name => 'cluster', type => 'round-robin', backends => [ 'server1', 'server2' ] }
#  ],
# }
#
# configure 2 probes, 4 backends and 2 directors
# for requests with URLs '^/cluster2' director is set to 'cluster2'
# otherwise director 'cluster' is used
# class {'varnish::vcl':
#   probes => [
#     { name => 'health_check',  url => "/health_check" },
#     { name => 'health_check2', url => "/health_check2" },
#   ],
#   backends => [
#     { name => 'server1', host => '192.168.1.1', port => '80', probe => 'health_check' },
#     { name => 'server2', host => '192.168.1.2', port => '80', probe => 'health_check' },
#     { name => 'server3', host => '192.168.1.3', port => '80', probe => 'health_check2' },
#     { name => 'server4', host => '192.168.1.4', port => '80', probe => 'health_check2' },
#   ],
#  directors => [
#    { name => 'cluster',  type => 'round-robin', backends => [ 'server1', 'server2' ] },
#    { name => 'cluster2', type => 'round-robin', backends => [ 'server3', 'server4' ] },
#  ],
#  selectors => [
#    { backend => 'cluster2', condition => 'req.url ~ "^/cluster2"' },
#    { backend => 'cluster2' },
# ],
# }
#

class varnish::vcl (
  $probes     = [],
  $backends   = [ { name => 'default', host => '127.0.0.1', port => '8080' } ],
  $directors  = [],
  $acls       = [],
  $selectors  = [],
  $conditions = [],
  $template   = undef,
) {

  include varnish

  # parameters for probe
  $probe_params = [ 'interval', 'timeout', 'threshold', 'window', 'url', 'request' ]

  # select template to use
  if $template {
    $template_vcl = $template
  }
  else {
    $template_vcl = 'varnish/varnish-vcl.erb'
  }

  # vcl file
  file { 'varnish-vcl':
    ensure  => present,
    path    => $varnish::varnish_vcl_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($template_vcl),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }
}
