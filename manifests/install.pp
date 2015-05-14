# == Class: varnish::install
#
# Installs Varnish.
#
# === Parameters
#
# version - passed to puppet type 'package', attribute 'ensure'
#
# === Examples
#
# install Varnish
# class {'varnish::install':}
#
# make sure latest version is always installed
# class {'varnish::install':
#  version => latest,
# }
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

  # varnish package
  package { 'varnish':
    ensure  => $varnish::version,
  }
}
