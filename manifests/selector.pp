#selector.pp
define varnish::selector(
  $condition,
  $director = $name,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
) {
  $template_selector = $::varnish::params::version ? {
    '4'     => 'varnish/includes/backendselection4.vcl.erb',
    default => 'varnish/includes/backendselection.vcl.erb',
  }

  concat::fragment { "${title}-selector":
    target  => "${varnish::vcl::includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => '03',
  }

}
