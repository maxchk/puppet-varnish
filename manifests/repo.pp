# Class varnish::repo
#
# This class installs aditional repos for varnish
#
class varnish::repo (
  $base_url = '',
  $enable = true,
  ) {

  $repo_base_url = 'http://repo.varnish-cache.org'

  $repo_distro = $::operatingsystem ? {
    'RedHat'    => 'redhat',
    'LinuxMint' => 'ubuntu',
    'centos'    => 'redhat',
    'amazon'    => 'redhat',
    default     => downcase($::operatingsystem),
  }

  $repo_version = $varnish::version ? {
    /^3\./  => '3.0',
    /^4\./  => '4.0',
    default => '3.0',
  }

  $repo_arch = $::architecture

  $osver_array = split($::operatingsystemrelease, '[.]')
  if downcase($::operatingsystem) == 'amazon' {
    $osver = $osver_array[0] ? {
      '2'     => '5',
      '3'     => '6',
      default => undef,
    }
  }
  else {
    $osver = $osver_array[0]
  }
  if str2bool($enable) {
    case $::osfamily {
      redhat: {
        yumrepo { 'varnish':
          descr          => 'varnish',
          enabled        => '1',
          gpgcheck       => '0',
          priority       => '1',
          baseurl        => "${repo_base_url}/${repo_distro}/varnish-${repo_version}/el${osver}/${repo_arch}",
        }
      }
      debian: {
        apt::source { 'varnish':
          location   => "${repo_base_url}/${repo_distro}",
          repos      => "varnish-${repo_version}",
          key        => 'C4DEFFEB',
          key_source => 'http://repo.varnish-cache.org/debian/GPG-key.txt',
        }
      }
      default: {
      }
    }
  }
}
