#director.pp
define varnish::director ( $type = 'round-robin',
                           $backends = [],
                        ) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name $title. Only letters, numbers and underscore are allowed.")

  concat {
    "${varnish::vcl::includedir}/directors.vcl":
      ensure => present, 
  }

  concat::fragment { "$title-director":
    target => "${varnish::vcl::includedir}/directors.vcl",
    content => template('varnish/includes/directors.vcl.erb'),
    order => '02',
  }

}
