# == Class: varnish::service
#
# Enables/Disables Varnish service
#
# === Parameters
#
# start - 'yes' or 'no' to start varnishd at boot
#          default value: 'yes'
#
# === Examples
#
# make sure Varnish is running
# class {'varnish::service':}
#
# disable Varnish
# class {'varnish::service':
#   start => 'no',
# }

class varnish::service (
  $start = 'yes',
) {

  # include install
  include varnish::install

  # set state
  $service_state = $start ? {
    'no'    => stopped,
    default => running,
  }
  $service_enable = $start ? {
    'no'    => false,
    default => true,
  }

  # varnish service
  $reload_cmd = $::osfamily ? {
    'debian'    => '/etc/init.d/varnish reload',
    'redhat'    => '/sbin/service varnish reload',
    default     => undef,
  }

  service {'varnish':
    ensure  => $service_state,
    enable  => $service_enable,
    restart => $reload_cmd,
    require => Package['varnish'],
  }

  $restart_command = $::osfamily ? {
    'debian'    => '/etc/init.d/varnish restart',
    'redhat'    => '/sbin/service varnish restart',
    default     => undef,
  }

  $status_command = $::osfamily ? {
    'debian'    => '/etc/init.d/varnish status',
    'redhat'    => '/sbin/service varnish status',
    default     => undef,
  }

  exec {'restart-varnish':
    command     => $restart_command,
    refreshonly => true,
    onlyif      => $status_command,
  }

  if $::osfamily == 'RedHat' {
    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {

      file { '/usr/lib/systemd/system/varnish.service':
        ensure => file,
        source => 'puppet:///modules/varnish/varnish.service',
        notify => Exec['Reload systemd'],
        before => Service['varnish'],
        require => Package['varnish'],
      }

      if (!defined(Exec['Reload systemd'])) {
        exec {'Reload systemd':
          command     => '/usr/bin/systemctl daemon-reload',
          refreshonly => true,
        }
      }

    }
  }
}
