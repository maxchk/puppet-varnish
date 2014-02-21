#acl.pp
define varnish::acl ( $hosts,
                    ) {

  concat::fragment { "$title-acl":
    target => "${varnish::vcl::includedir}/acls.vcl",
    content => template('varnish/includes/acls.vcl.erb'),
    order => '02',
  }

}
