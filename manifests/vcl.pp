# == Class: varnish::vcl
#
# to change name/location of vcl file, use $varnish_vcl_conf in the main varnish class
#
# === Parameters
#
# probes     - list of probes to configure, must be an array of hashes:
#              {
#                probe1 => { url = '/healthcheck1' },
#                probe2 => { url = '/healthcheck2' },
#              }
#              you can provide any Varnish .probe parameters
#              just drop the . and use key => val syntax:
#              timeout => '5s', window => '8', and so on
#
# backends   - list of backends to configure, must be a hash
#              {
#                'srv1' => { host => '10.0.0.1', port => '80' },
#                'srv2' => { host => '10.0.0.2', port => '80' },
#              }
#              you can provide any Varnish .backend parameters in the same way as for probes
#
# directors  - list of directors to configure, must be an array of hashes
#              {
#                director1 => { type => 'round-robin', backends => [ 'srv1', 'srv2' ] },
#                director2 => { type => 'round-robin', backends => [ 'srv3', 'srv4' ] },
#              }
#
# selectors  - list of selectors, configured only when multiple backends/directors are in use
#              will be configured in the same order as listed in manifest. Must be a Hash
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
#  ],
#  acls => [
#    { name => 'acl1', hosts => [ '"localhost"', '"10.0.0.0"/8' ] },
#  ],
# }
#

class varnish::vcl (
  $probes            = {},
  $backends          = { 'default' => { host => '127.0.0.1', port => '8080' } },
  $directors         = [],
  $selectors         = [],
  $conditions        = [],
  $acls              = {},
  $blockedips	     = [],
  $blockedbots	     = [],
  $wafexceptions     = [ "57" , "56" , "34" ],
  $purgeips          = [], 
  $includedir        = "/etc/varnish/includes",
  $cookiekeeps       = [ '__ac', '_ZopeId', 'captchasessionid', 'statusmessages', '__cp', 'MoodleSession'],
  $defaultgrace      = undef,
  $min_cache_time    = "60s",
  $static_cache_time = "5m",
  $gziptypes         = [ 'text/', 'application/xml', 'application/rss', 'application/xhtml', 'application/javascript', 'application/x-javascript' ],
  $template          = undef,
) {

  include varnish

  # parameters for probe
  $probe_params = [ 'interval', 'timeout', 'threshold', 'window', 'url', 'request' ]

  # define include file type
  define includefile {
    $selectors = $varnish::vcl::selectors
    concat { "${varnish::vcl::includedir}/$title.vcl":
       owner          => 'root',
       group          => 'root',
       mode           => '0444',
       notify         => Service['varnish'],
       require        => File["${varnish::vcl::includedir}"],
    }

    concat::fragment { "$title-header":
       target => "${varnish::vcl::includedir}/$title.vcl",
       content => '# File managed by Puppet
',
       order => '01',
    }
  }


  # select template to use
  if $template {
    $template_vcl = $template
  }
  else {
    $template_vcl = 'varnish/varnish-vcl.erb'
    file { "$includedir":
	ensure => directory,	
    }
    $includefiles = ["probes", "backends", "directors", "acls", "backendselection", "waf"]
    includefile { $includefiles: }
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
  }

  # web application firewall
  concat::fragment { "waf":
    target => "${varnish::vcl::includedir}/waf.vcl",
    content => template('varnish/includes/waf.vcl.erb'),
    order => '02',
  }


  #Create resources
 
  #Backends
  validate_hash($backends)
  create_resources(varnish::backend,$backends) 

  #Probes
  validate_hash($probes)
  create_resources(varnish::probe,$probes) 
  
  #Directors
  validate_hash($directors)
  create_resources(varnish::director,$directors)

  #Selectors
  validate_hash($selectors)
  concat::fragment { "selectors-header":
    target => "${varnish::vcl::includedir}/backendselection.vcl",
    content => 'if ( false ) { 
',
    order => '02',
  }
  create_resources(varnish::selector,$selectors)
  concat::fragment { "selectors-footer":
    target => "${varnish::vcl::includedir}/backendselection.vcl",
    content => '} else { error 403 "Access denied"; }',
    order => '99',
  }

  #ACLs
  validate_hash($acls)
  $default_acls = { 
    blockedips => { hosts => $blockedips },
    purge => { hosts => $purgeips },
  } 
  $all_acls = merge($default_acls, $acls)
  create_resources(varnish::acl,$all_acls) 
}
