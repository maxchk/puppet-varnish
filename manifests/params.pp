# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        $conf_file_path = '/etc/sysconfig/varnish'
      }
    }
    default: {
      $conf_file_path = '/etc/default/varnish'
    }
  }

  $version = $varnish::version ? {
    /4\..*/ => '4',
    default => 3,
  }
}
