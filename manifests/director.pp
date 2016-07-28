#director.pp
define varnish::director(
  $type = 'round-robin',
  $backends = [],
) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name ${title}. Only letters, numbers and underscore are allowed.")

  if versioncmp($::varnish::real_version, '4') >= 0 {
    $template_director = 'varnish/includes/directors4.vcl.erb'
    $director_object = $type ? {
      'round-robin' => 'round_robin',
      'client' => 'hash',
      default => $type
    }
  } else {
    $template_director = 'varnish/includes/directors.vcl.erb'
  }

  concat::fragment { "${title}-director":
    target  => "${varnish::vcl::includedir}/directors.vcl",
    content => template($template_director),
    order   => '02',
    notify  => Service['varnish'],
  }
}
