# == Class: varnish::install
#
# Installs Varnish.
#
# === Parameters
#
# ensure - passed to puppet type 'package', attribute 'ensure'
#
# === Examples
#
# install Varnish
# class {'varnish::install':}
#
#

class varnish::install (
  $add_repo = true,
  $manage_firewall = false,
  $varnish_listen_port = '6081',
) {
  class { 'varnish::repo':
    enable => $add_repo,
    before => Package['varnish'],
  }

  class { 'varnish::firewall':
    manage_firewall     => $manage_firewall,
    varnish_listen_port => $varnish_listen_port,
  }

  # Varnish package
  package { 'varnish':
    ensure => $varnish::ensure,
  }
}
