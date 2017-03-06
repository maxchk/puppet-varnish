#selector.pp
define varnish::selector(
  $condition,
  $director = $name,
  $backend = undef,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
  $order = 10,
) {
  if versioncmp($::varnish::real_version, '4') >= 0 {
    $template_selector = 'varnish/includes/backendselection4.vcl.erb'
  } else {
    $template_selector = 'varnish/includes/backendselection.vcl.erb'
  }

  if $backend {
    $_backend = $backend
  } else {
    $_backend = "${director}.backend()"
  }

  concat::fragment { "${title}-selector":
    target  => "${varnish::vcl::includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => $order,
    notify  => Service['varnish'],
  }

}
