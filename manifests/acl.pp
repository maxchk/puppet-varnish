#acl.pp
define varnish::acl(
  $hosts,
) {

  # Varnish does not allow empty ACLs
  if size($hosts) > 0 {
    validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in ACL name ${title}. Only letters, numbers and underscore are allowed.")

    concat::fragment { "${title}-acl":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => template('varnish/includes/acls.vcl.erb'),
      order   => '02',
    }
  }
}
