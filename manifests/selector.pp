#selector.pp
define varnish::selector(
  $director = $name,
  $condition,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
) {

  concat::fragment { "${title}-selector":
    target  => "${varnish::vcl::includedir}/backendselection.vcl",
    content => template('varnish/includes/backendselection.vcl.erb'),
    order   => '03',
  }

}
