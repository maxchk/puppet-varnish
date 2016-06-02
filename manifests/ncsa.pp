class varnish::ncsa (
  $enable = true,
  $varnishncsa_daemon_opts = undef,
  $log_format = undef,
) {

  file { '/etc/default/varnishncsa':
    ensure  => 'file',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('varnish/varnishncsa-default.erb'),
    notify  => Service['varnishncsa'],
  }

  # TODO: This is a hacky workaround for issues with `start-stop-daemon`
  # misinterpretting quoted arguments. See http://stackoverflow.com/q/1661193
  # and also https://github.com/varnishcache/pkg-varnish-cache/pull/33.
  file { '/etc/init.d/varnishncsa':
    ensure  => 'file',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('varnish_cache/varnishncsa.debian.erb'),
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
