# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  case $::osfamily {
    'RedHat': {
      $default_version = '3'
      $add_repo = true
      $vcl_reload_script = '/usr/sbin/varnish_reload_vcl'
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $systemd_conf_path = '/usr/lib/systemd/system/varnish.service'
        $systemd = true
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        $systemd = false
        $conf_file_path = '/etc/sysconfig/varnish'
      }
    }
    'Debian': {
      $vcl_reload_script = '/usr/share/varnish/reload-vcl'
      if ($::service_provider == 'systemd') {
        $systemd = true
        $systemd_conf_path = '/lib/systemd/system/varnish.service'
      } else {
        $systemd = false
      }
      if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '15.10') > 0) {
        #don't add repo as in default repo
        $add_repo = false
        $conf_file_path = '/etc/varnish/varnish.params'
        $default_version ='4'
      } else {
        $add_repo = true
        $conf_file_path = '/etc/default/varnish'
        $default_version = '3'

      }
    }
    default: {
      fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
    }
  }
}
