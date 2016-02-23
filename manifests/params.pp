# == Class: varnish::params
#

class varnish::params {
  # set Varnish conf/systemd location based on OS
  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $systemd            = true
        $systemctl_bin      = '/usr/bin/systemctl'
        $varnish_reload_bin = '/usr/sbin/varnish_reload_vcl'
      } else {
        $systemd = false
        $conf_file_path = '/etc/sysconfig/varnish'
      }
    }
    'Debian': {
      $systemctl_bin      = '/bin/systemctl'
      $systemd            = false
      $conf_file_path     = '/etc/default/varnish'
      $varnish_reload_bin = '/usr/share/varnish/reload-vcl'
    }
    default: {
      $varnish_reload_bin = '/usr/sbin/varnish_reload_vcl'
      $systemctl_bin      = '/usr/bin/systemctl'
      $systemd            = false
      $conf_file_path     = '/etc/default/varnish'
    }
  }
}
