# Class varnish::repo
#
# This class installs aditional repos for varnish
#
class varnish::repo (
  $base_url = '',
  ) {

  $repo_base_url = $base_url ? {
    ''   => $::osfamily ? {
      'RedHat' => 'http://repo.varnish-cache.org',
      'Debian' => 'http://repo.varnish-cache.org/ubuntu/',
    }
  }

  $repo_distro = $::operatingsystem ? {
    'RedHat'    => 'redhat',
    'LinuxMint' => 'ubuntu',
    default     => downcase($::operatingsystem),
  }

  $repo_version = $varnish::version ? {
    /^3\./  => '3.0',
    /^4\./  => '4.0',
    default => '3.0',
  }

  $repo_arch = $::architecture ? {
    /^.*86$/ => 'x86',
    /^.*64$/ => 'amd64',
    default  => $::architecture,
  }

  $osver = split($::operatingsystemrelease, '[.]')

  case $::osfamily {
    redhat: {
      yumrepo { 'varnish':
        descr          => 'varnish',
        enabled        => '1',
        gpgcheck       => '0',
        baseurl        => "${repo_base_url}/${repo_distro}/varnish-${repo_version}/${osver[0]}/${repo_arch}",
      }
    }
    debian: {
      apt::source { 'varnish':
        location   => "${repo_base_url}/${repo_distro}",
        repos      => "varnish-${repo_version}",
        key_source => 'http://repo.varnish-cache.org/debian/GPG-key.txt',
      }
    }
    default: {
    }
  }
}
