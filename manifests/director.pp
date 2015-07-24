#director.pp
define varnish::director(
  $type = 'round-robin',
  $backends = [],
) {

  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name ${title}. Only letters, numbers and underscore are allowed.")

  $template_director = $::varnish::params::version ? {
    4       => 'varnish/includes/directors4.vcl.erb',
    default => 'varnish/includes/directors.vcl.erb',
  }

  if $template_director == 'varnish/includes/directors4.vcl.erb' {
    $director_object = $type ? {
      'round-robin' => 'round_robin',
      'client' => 'hash',
      default => $type
    }
  }

concat::fragment { "${title}-director":
    target  => "${varnish::vcl::includedir}/directors.vcl",
    content => template($template_director),
    order   => '02',
  }
}
