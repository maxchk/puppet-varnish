class varnish::ncsa (
  $enable = true,
  $varnishncsa_daemon_opts = undef,
) {

  file { '/etc/default/varnishncsa':
    ensure => 'present',
    mode => '0644',
    owner => 'root',
    group => 'root',
    content => template('varnish/varnishncsa-default.erb'),
    notify => Service['varnishncsa'],
  }

  service { 'varnishncsa':
    enable  => $enable,
    ensure  => $enable ? {
      true => 'running',
      default => 'stopped',
    },
    require => Service["varnish"],
    subscribe => File['/etc/default/varnishncsa'],
  }

}
