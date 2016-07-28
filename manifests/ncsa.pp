class varnish::ncsa (
  $enable = true,
  $varnishncsa_daemon_opts = undef,
  $log_format = undef,
) {

  $log_format_file = '/etc/varnish/ncsa-format'

  # TODO: We should raise an error if a custom log format is specified when
  # `versioncmp($::varnish::real_version, '4') < 0`. This is not trivial to do,
  # however, because it is currently possible to use `Class['varnish::ncsa']`
  # without using `Class['varnish']`. One possible solution here is to add a
  # `$::varnish_version` fact.
  if $log_format {
    $format_ensure  = 'file'
    $format_content = $log_format
  } else {
    $format_ensure  = 'absent'
    $format_content = undef
  }

  file { $log_format_file:
    ensure  => $format_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $format_content,
    notify  => Service['varnishncsa'],
    require => Package['varnish'],
  }

  file { '/etc/default/varnishncsa':
    ensure  => 'file',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('varnish/varnishncsa-default.erb'),
    notify  => Service['varnishncsa'],
  }

  $service_ensure = $enable ? {
    true => 'running',
    default => 'stopped',
  }

  service { 'varnishncsa':
    ensure    => $service_ensure,
    enable    => $enable,
    require   => Service['varnish'],
    subscribe => File['/etc/default/varnishncsa'],
  }

}
