#acl.pp
define varnish::acl(
  $hosts,
) {

  # Varnish does not allow empty ACLs
  if size($hosts) > 0 {
    validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in ACL name ${title}. Only letters, numbers and underscore are allowed.")

    unless defined(Concat::Fragment["${title}-acl_head"]) {
      concat::fragment { "${title}-acl_head":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "acl ${title} {\n",
        order   => "02-${title}-1-0",
        notify  => Service['varnish'],
      } -> concat::fragment { "${title}-acl_tail":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "}\n",
        order   => "02-${title}-3-0",
        notify  => Service['varnish'],
      }
    }
    concat::fragment { "${title}-acl_body":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => template('varnish/includes/acls_body.vcl.erb'),
      order   => "02-${title}-2-0",
      notify  => Service['varnish'],
    }
  }
}

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
