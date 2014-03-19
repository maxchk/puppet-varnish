#director.pp
define varnish::director ( $type = 'round-robin',
                           $backends = [],
                        ) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name $title. Only letters, numbers and underscore are allowed.")

  if $title == 'default' {
    $set_target = "${varnish::vcl::includedir}/default_director.vcl"
  } else {
    $set_target = "${varnish::vcl::includedir}/directors.vcl"
  }
    
  concat::fragment { "$title-director":
    target => $set_target,
    content => template('varnish/includes/directors.vcl.erb'),
    order => '02',
  }
}
