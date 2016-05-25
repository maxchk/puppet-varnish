# == Class: varnish::shmlog
#
# Mounts shmlog as tempfs
#
# === Parameters
#
# shmlog_dir - directory where Varnish logs
#
# tempfs     - mount or not shmlog as tmpfs, boolean
#              default value: true
#
# === Examples
#
# disable config for mounting shmlog as tmpfs
# class {'varnish::shmlog':
#   tempfs => false,
# }
#

class varnish::shmlog (
  $shmlog_dir = '/var/lib/varnish',
  $tempfs     = true,
  $size       = '170M',
) {

  file { 'shmlog-dir':
    ensure  => directory,
    path    => $shmlog_dir,
    seltype => 'varnishd_var_lib_t',
  }

  # mount shared memory log dir as tmpfs
  $shmlog_share_state = $tempfs ? {
    true    => mounted,
    default => absent,
  }

  $options = $::selinux ? {
    true    => "defaults,noatime,size=${size},rootcontext=system_u:object_r:varnishd_var_lib_t:s0",
    default => "defaults,noatime,size=${size}",
  }

  mount { 'shmlog-mount':
    ensure  => $shmlog_share_state,
    name    => $shmlog_dir,
    target  => '/etc/fstab',
    fstype  => 'tmpfs',
    device  => 'tmpfs',
    options => $options,
    pass    => '0',
    dump    => '0',
    notify  => Service['varnish'],
    require => File['shmlog-dir'],
  }
}
