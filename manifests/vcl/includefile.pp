# Defined type varnish::vcl::includefile
#
define varnish::vcl::includefile {
  $selectors = $varnish::vcl::selectors
  concat { "${varnish::vcl::includedir}/${title}.vcl":
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['varnish'],
    require => File[$varnish::vcl::includedir],
    before  => Exec['restart-varnish'],
  }

  concat::fragment { "${title}-header":
    target  => "${varnish::vcl::includedir}/${title}.vcl",
    content => "# File managed by Puppet\n",
    order   => '01',
  }
}
