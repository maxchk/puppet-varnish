#backend.pp
define varnish::backend ( $host,
                          $port,
                          $probe,
                        ) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in backend name $title. Only letters, numbers and underscore are allowed.")

  concat::fragment { "$title-backend":
    target => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order => '02',
  }

}
