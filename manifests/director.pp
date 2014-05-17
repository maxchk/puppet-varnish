#director.pp
define varnish::director(
  $type = 'round-robin',
  $backends = [],
) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name ${title}. Only letters, numbers and underscore are allowed.")

  concat::fragment { "${title}-director":
    target  => "${varnish::vcl::includedir}/directors.vcl",
    content => template('varnish/includes/directors.vcl.erb'),
    order   => '02',
  }
}
