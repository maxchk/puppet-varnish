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
#       See README for details on how to use those
#
# === Parameters
#
# enable_waf - controls VCL WAF component, can be true or false
#              default value: false
# pipe_uploads - If the request is a post/put upload (chunked or multipart),
#                pipe the request to the backend.
#                default value: false
#
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
class varnish::vcl (
  $probes            = {},
  $backends          = { 'default' => { host => '127.0.0.1', port => '8080' } },
  $directors         = {},
  $selectors         = {},
  $conditions        = [],
  $acls              = {},
  $blockedips        = [],
  $blockedbots       = [],
  $enable_waf        = false,
  $pipe_uploads      = false,
  $wafexceptions     = [ '57' , '56' , '34' ],
  $purgeips          = [],
  $includedir        = '/etc/varnish/includes',
  $manage_includes   = true,
  $cookiekeeps       = [ '__ac', '_ZopeId', 'captchasessionid', 'statusmessages', '__cp', 'MoodleSession'],
  $defaultgrace      = undef,
  $min_cache_time    = '60s',
  $static_cache_time = '5m',
  $gziptypes         = [ 'text/', 'application/xml', 'application/rss', 'application/xhtml', 'application/javascript', 'application/x-javascript' ],
  $template          = undef,
  $logrealip         = false,
  $honor_backend_ttl = false,
  $cond_requests     = false,
  $x_forwarded_proto = false,
  $https_redirect    = false,
  $drop_stat_cookies = true,
  $cond_unset_cookies = undef,
) {

  include varnish

  # define include file type
  define includefile {
    $selectors = $varnish::vcl::selectors
    concat { "${varnish::vcl::includedir}/${title}.vcl":
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      notify  => Service['varnish'],
      require => File[$varnish::vcl::includedir],
    }

    concat::fragment { "${title}-header":
      target  => "${varnish::vcl::includedir}/${title}.vcl",
      content => "# File managed by Puppet\n",
      order   => '01',
    }
  }


  # select template to use
  if $template {
    $template_vcl = $template
  }
  else {
    $template_vcl = $::varnish::params::version ? {
      '4'     => 'varnish/varnish4-vcl.erb',
      default => 'varnish/varnish-vcl.erb',
    }
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

  if $template == undef or $manage_includes {
    file { $includedir:
      ensure  => directory,
      require => Package['varnish'],
    }
    $includefiles = ['probes', 'backends', 'directors', 'acls', 'backendselection', 'waf']

    varnish::vcl::includefile { $includefiles: }

    # web application firewall
    concat::fragment { 'waf':
      target  => "${varnish::vcl::includedir}/waf.vcl",
      content => template('varnish/includes/waf.vcl.erb'),
      order   => '02',
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
    create_resources(varnish::selector,$selectors)

    #ACLs
    validate_hash($acls)
    $default_acls = {
      blockedips => { hosts => $blockedips },
      purge => { hosts => $purgeips },
    }
    $all_acls = merge($default_acls, $acls)
    create_resources(varnish::acl,$all_acls)
    Varnish::Acl_member <| varnish_fqdn == $::fqdn |>
  }
}
