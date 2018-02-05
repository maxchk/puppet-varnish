# Class varnish::repo
#
# This class installs aditional repos for varnish
#
class varnish::repo (
  $base_url = '',
  $enable = true,
  ) {

  $repo_base_url = 'https://packagecloud.io'

  $repo_distro = $::operatingsystem ? {
    'RedHat'    => 'el',
    'LinuxMint' => 'ubuntu',
    'centos'    => 'el',
    'amazon'    => 'el',
    default     => downcase($::operatingsystem),
  }

  $repo_arch = $::architecture
  $repo_version = regsubst($varnish::real_version, '^(\d+)\.(\d+)$', '\1\2')

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
          descr         => 'varnish',
          enabled       => '1',
          gpgcheck      => '0',
          repo_gpgcheck => '1',
          gpgkey        => "${repo_base_url}/varnishcache/varnish${$repo_version}/gpgkey",
          priority      => '1',
          baseurl       => "${repo_base_url}/varnishcache/varnish${repo_version}/${repo_distro}/${osver}/\$basearch",
        }
      }

      debian: {
        case $repo_version {
            '30': {
              $key_id = '246BE381150865E2DC8C6B01FC1318ACEE2C594C'
            }
            '40': {
              $key_id = 'B7B16293AE0CC24216E9A83DD4E49AD8DE3FFEA4'
            }
            '41': {
              $key_id = '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E'
            }
            '50': {
              $key_id = '1487779B0E6C440214F07945632B6ED0FF6A1C76'
            }
            '51': {
              $key_id = '54DC32329C37703D8B2819E6414C46826B880524'
            }
            '52': {
              $key_id = '91CFD5635A1A5FAC0662BEDD2E9BA3FE86BE909D'
            }
            default: {
              fail("Repo version ${repo_version} not supported")
            }
          }

        apt::source { 'varnish':
          location => "${repo_base_url}/varnishcache/varnish${repo_version}/${repo_distro}",
          repos    => 'main',
          key      => {
            id     => $key_id,
            source => "${repo_base_url}/varnishcache/varnish${$repo_version}/gpgkey"
          },
        }
      }
      default: {
      }
    }
  }
}
