# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  case $::osfamily {
    'RedHat': {
      $default_version = '3'
      $add_repo = true
      $vcl_reload_script = '/usr/sbin/varnish_reload_vcl'
      if ($::service_provider == 'systemd') {
        $systemd = true
        $systemd_conf_path = '/usr/lib/systemd/system/varnish.service'
      } else {
        $systemd = false
      }
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        $conf_file_path = '/etc/sysconfig/varnish'
      }
    }
    'Debian': {
      $vcl_reload_script = '/usr/share/varnish/reload-vcl'
      if ($::service_provider == 'systemd' or
          ($::operatingsystem == 'Ubuntu' and 
          versioncmp($::operatingsystemmajrelease, '15.10') > 0)) {
        $systemd = true
        $systemd_conf_path = '/etc/systemd/system/varnish.service'
        $systemd_ncsa_conf_path = '/etc/systemd/system/varnishncsa.service'
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        $systemd = false
        $conf_file_path = '/etc/default/varnish'
      }
      if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '15.10') > 0) {
        #don't add repo as in default repo
        $add_repo = false
        $default_version ='4'
      } elsif ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '7') > 0) {
        #don't add repo as in default repo
        $add_repo = false
        $default_version ='4'
      }
      else {
        $add_repo = true
        $default_version = '3'

      }
    }
    default: {
      fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
    }
  }
}
