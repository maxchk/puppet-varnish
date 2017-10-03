# Defined type varnish::acl_member
define varnish::acl_member(
  $varnish_fqdn,
  $acl,
  $host,
) {
  unless defined(Concat::Fragment["${acl}-acl_head"]) {
    concat::fragment { "${acl}-acl_head":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => "acl ${acl} {\n",
      order   => "02-${acl}-1-0",
      notify  => Service['varnish'],
    } -> concat::fragment { "${acl}-acl_tail":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => "}\n",
      order   => "02-${acl}-3-0",
      notify  => Service['varnish'],
    }
  }
  $hosts = [$host]
  concat::fragment { "${acl}-acl_${host}":
    target  => "${varnish::vcl::includedir}/acls.vcl",
    content => template('varnish/includes/acls_body.vcl.erb'),
    order   => "02-${acl}-2-${host}",
    notify  => Service['varnish'],
  }
}
