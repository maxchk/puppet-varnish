#probe.pp
define varnish::probe(
  $interval  = '5s',
  $timeout   = '5s',
  $threshold = '3',
  $window    = '8',
  $url       = undef,
  $request   = undef
) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in probe name ${title}. Only letters, numbers and underscore are allowed.")

  # parameters for probe
  $probe_params = [ 'interval', 'timeout', 'threshold', 'window', 'url', 'request' ]

  concat::fragment { "${title}-probe":
    target  => "${varnish::vcl::includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order   => '02',
    notify  => Service['varnish'],
  }

}
