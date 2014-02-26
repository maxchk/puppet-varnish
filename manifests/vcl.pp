# == Class: varnish::vcl
#
# to change name/location of vcl file, use $varnish_vcl_conf in the main varnish class
#
# NOTE: though you can pass config for backends, directors, acls, probes and selectors
#       as parameters to this class, it is recommended to use existing definitions instead:
#       varnish::backend
#       varnish::director
#       varnish::probe
#       varnish::acl
#       varnish::selector
#
# === Parameters
#
# probes     - list of probes to configure, must be a hash:
#    probes => {
#      'health_check1' => { url => '/health_check_url1' },
#      'health_check2' => {
#        window    => '8',
#        timeout   => '5s',
#        threshold => '3',
#        interval  => '5s',
#        request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
#      }
#    }
#    NOTE: available probes are defined by array $probe_params in varnish::probe definition
#          $probe_params = [ 'interval', 'timeout', 'threshold', 'window', 'url', 'request' ]
#
#
# backends   - list of backends to configure, must be a hash
#    backends => {
#      'srv1' => { host => '172.16.0.1', port => '80', probe => 'health_check1' },
#      'srv2' => { host => '172.16.0.2', port => '80', probe => 'health_check1' },
#      'srv3' => { host => '172.16.0.3', port => '80', probe => 'health_check2' },
#      'srv4' => { host => '172.16.0.4', port => '80', probe => 'health_check2' },
#      'srv5' => { host => '172.16.0.5', port => '80', probe => 'health_check2' },
#      'srv6' => { host => '172.16.0.6', port => '80', probe => 'health_check2' }
#    }
#
#
# directors  - list of directors to configure, must be a hash
#              you can also provide $type which by default is set to 'round-robin'
#    directors => {
#      'cluster1' => { backends => [ 'srv1', 'srv2' ] },
#      'cluster2' => { backends => [ 'srv3', 'srv4', 'srv5', 'srv6' ] }
#    }
#
#
# acls       - list of acls to configure, must be a hash
#              NOTE: acl names 'blockedips' and 'purge' are reserved
#                    and cannot be set by this parameter.
#                    They exist as separate parameters for this class (see below)
#              TODO: need to work out how to pass ! to acl, i.e.
#                    acl blah {
#                      "172.16.1.0"/24;
#                      ! "172.16.1.1";
#                    }
#    acls => {
#      'acl1' => { hosts => [ "localhost", "172.16.0.1" ] },
#      'acl2' => { hosts => [ "localhost", "192.168.0.0/24" ] }
#    }
#
#
# selectors  - list of selectors, configured only when multiple backends/directors are in use
#              will be configured in the same order as listed in manifest. Must be a Hash
#    selectors => {
#      'cluster1' => { condition => 'req.url ~ "^/cluster1"' },
#      'cluster2' => { condition => 'true' } # will act as backend set by else statement
#    }
#
#
# conditions - list of conditions to apply, must be an array of hashes
#
# template   - you can build your own template and pass it to thei class with option template
#              please make sure your template uses same vars and datatypes as original one
#
#
# NOTE: VCL applies following restictions:
# - if you define an acl it must be used
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
# subdir tests has a number of examples on using either varnish::vsl class,
# as well as varnish::backend, varnish::director, etc. definitions
#
class varnish::vcl (
  $probes            = {},
  $backends          = { 'default' => { host => '127.0.0.1', port => '8080' } },
  $directors         = {},
  $selectors         = {},
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
    require => Package['varnish'],
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
    content => 'if (false) {
',
    order => '02',
  }
  create_resources(varnish::selector,$selectors)
  concat::fragment { "selectors-footer":
    target => "${varnish::vcl::includedir}/backendselection.vcl",
    content => '} else {
  error 403 "Access denied";
}
',
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
