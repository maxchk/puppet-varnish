#probe.pp
define varnish::probe ( $interval,
                        $timeout,
                        $threshold,
                        $window,
                        $url = undef,
                        $request = undef
                      ) {

  concat::fragment { "$title-probe":
    target => "${varnish::vcl::includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order => '02',
  }

}
