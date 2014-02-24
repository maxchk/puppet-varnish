#probe.pp
define varnish::probe ( $interval,
                        $timeout,
                        $threshold,
                        $window,
                        $url = undef,
                        $request = undef
                      ) {

  # parameters for probe
  $probe_params = [ 'interval', 'timeout', 'threshold', 'window', 'url', 'request' ]

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in probe name $title. Only letters, numbers and underscore are allowed.")

  concat::fragment { "$title-probe":
    target => "${varnish::vcl::includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order => '02',
  }

}
