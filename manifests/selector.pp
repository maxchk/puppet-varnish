#selector.pp
define varnish::selector(
  $condition,
  $director = $name,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
) {
  if versioncmp($::varnish::real_version, '4') >= 0 {
    $template_selector = 'varnish/includes/backendselection4.vcl.erb'
  } else {
    $template_selector = 'varnish/includes/backendselection.vcl.erb'
  }

  concat::fragment { "${title}-selector":
    target  => "${varnish::vcl::includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => '03',
    notify  => Service['varnish'],
  }

}
