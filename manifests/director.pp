#director.pp
define varnish::director ( $type = 'round-robin',
                           $backends = [],
                        ) {

  concat::fragment { "$title-director":
    target => "${varnish::vcl::includedir}/directors.vcl",
    content => template('varnish/includes/directors.vcl.erb'),
    order => '02',
  }

}
