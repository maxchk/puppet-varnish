# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  case $::osfamily {
    'RedHat': {
      $default_version = '3'
      $add_repo = true
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
      if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '15.10')) {
        #don't add repo as in default repo
        $add_repo = false
        $systemd_conf_path = '/lib/systemd/system/varnish.service'
        $systemd = true
        $conf_file_path = '/etc/varnish/varnish.params'
        $default_version ='4'
      } else {
        $add_repo = true
        $systemd = false
        $conf_file_path = '/etc/default/varnish'
        $default_version = '3'
      }
    }
    default: {
      fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
    }
  }
}
