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
  $version = present,
) {

  # varnish package
  package { 'varnish':
    ensure  => $version,
  }
}
