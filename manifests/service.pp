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

  # varnish service
  service {'varnish':
    ensure  => $service_state,
    require => Package['varnish'],
  }
}
