##Table of Contents
1. [Overview](#overview)
2. [Install Varnish](#install-varnish)
3. [Class varnish](#class-varnish)
4. [Class varnish::vcl](#class-varnish-vcl)
    * [varnish::acl](varnish-acl)
    * [varnish::probe](varnish-probe)
    * [varnish::backend](varnish-backend)
    * [varnish::director](varnish-director)
    * [varnish::selector](varnish-selector)
5. [Configure VCL with class varnish::vcl](#configure-vcl-with-class-varnish-vcl)
6. [Class varnish::ncsa](#class-varnish-ncsa)
7. [Tests](#tests)
8. [Development](#development)
9. [Contributors](#contributors)

## Overview

   This Puppet module installs and configures Varnish.  
   It also allows to manage Varnish VCL.  
   Tested on Ubuntu, CentOS, RHEL and Oracle Linux.

## Install Varnish

   installs Varnish  
   allocates for cache 1GB (malloc)  
   starts it on port 80:  

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

## Class varnish

   Class `varnish`  
   Installs Varnish.  
   Provides access to all configuration parameters.  
   Controls Varnish service.  
   By default mounts shared memory log directory as tmpfs.  

   All parameters are low case replica of actual parameters passed to  
   the Varnish conf file, `$class_parameter -> VARNISH_PARAMETER`, i.e.  
   
    $memlock             -> MEMLOCK
    $varnish_vcl_conf    -> VARNISH_VCL_CONF
    $varnish_listen_port -> VARNISH_LISTEN_PORT

   Exceptions are:  
   `shmlog_dir`    - location for shmlog  
   `shmlog_tempfs` - mounts shmlog directory as tmpfs, (default value: true)  
   `version`       - passes to puppet type 'package', attribute 'ensure', (default value: present)  

   At minimum you may want to change a value for default port:  
   `varnish_listen_port => '80'`

For more details on parameters, check class varnish.

## Class varnish vcl

   Class `varnish::vcl` manages Varnish VCL configuration.  

   Varnish VCL applies following restictions:  
   if you define an acl it must be used  
   if you define a probe it must be used  
   if you define a backend it must be used  
   if you define a director it must be used  

   Gives access to Varnish acl, probe, backend, director, etc. definitions  
   (see below)  

### varnish acl

   Definition `varnish::acl` allows to configure Varnish acl.

    varnish::acl { 'acl1': hosts => [ "localhost", "172.16.0.1" ] }

### varnish probe

   Definition `varnish::probe` allows to configure Varnish probe.

    varnish::probe { 'health_check1': url => '/health_check_url1' }

### varnish backend

   Definition `varnish::backend` allows to configure Varnish backend.  
   If you have a single backend, you can name it `default` and ignore  
   `selector` sections.  
   For more examples see `tests/vcl_backend_default.pp` and `tests/vcl_backends.pp`

    varnish::backend { 'srv1': host => '172.16.0.1', port => '80', probe => 'health_check1' }
    varnish::backend { 'srv2': host => '172.16.0.2', port => '80', probe => 'health_check1' }

### varnish director

   Definition `varnish::director` allows to configure Varnish director.  
   For more examples see `tests/vcl_backends_probes_directors.pp`

    varnish::director { 'cluster1': backends => [ 'srv1', 'srv2' ] }

### varnish selector

   Definition `varnish::selector` allows to configure Varnish selector.  

   While `acl`, `probe`, `backend` and `director` are self-explanatory  
   WTF is `selector`?   

   You cannot define 2 or more backends/directors and not to use them.  
   This will result in VCL compilation failure.  

   Parameter `selectors` gives access to req.backend inside `vcl_recv`.  
   Code:  

    varnish::selector { 'cluster1': condition => 'req.url ~ "^/cluster1"' }
    varnish::selector { 'cluster2': condition => 'true' } # will act as backend set by else statement

   Will result in following VCL configuration to be generated:

    if (req.url ~ "^/cluster1") {
      set req.backend = cluster1;
    }
    if (true) {
      set req.backend = cluster2;
    }

   For more examples see `tests/vcl_backends_probes_directors.pp`

## Usaging class varnish::vcl

   Configure probes, backends, directors and selectors  

    class { 'varnish::vcl': }

    # configure probes
    varnish::probe { 'health_check1': url => '/health_check_url1' }
    varnish::probe { 'health_check2':  
      window    => '8',
      timeout   => '5s',
      threshold => '3',
      interval  => '5s',
      request   => [ "GET /healthCheck2 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
    }

    # configure backends
    varnish::backend { 'srv1': host => '172.16.0.1', port => '80', probe => 'health_check1' }
    varnish::backend { 'srv2': host => '172.16.0.2', port => '80', probe => 'health_check1' }
    varnish::backend { 'srv3': host => '172.16.0.3', port => '80', probe => 'health_check2' }
    varnish::backend { 'srv4': host => '172.16.0.4', port => '80', probe => 'health_check2' }
    varnish::backend { 'srv5': host => '172.16.0.5', port => '80', probe => 'health_check2' }
    varnish::backend { 'srv6': host => '172.16.0.6', port => '80', probe => 'health_check2' }

    # configure directors
    varnish::director { 'cluster1': backends => [ 'srv1', 'srv2' ] }
    varnish::director { 'cluster2': backends => [ 'srv3', 'srv4', 'srv5', 'srv6' ] }

    # configure selectors
    varnish::selector { 'cluster1': condition => 'req.url ~ "^/cluster1"' }
    varnish::selector { 'cluster2': condition => 'true' } # will act as backend set by else statement

   If modification to Varnish VCL goes further than configuring `probes`, `backends` and `directors`  
   parameter `template` can be used to point `varnish::vcl` class at a different template.  

   NOTE: If you copy existing template and modify it you will still  
   be able to use `probes`, `backends`, `directors` and `selectors`.  

## Class varnish ncsa

   Class `varnish::ncsa` manages varnishncsa configuration.  
   To enable varnishncsa:

     class {'varnish::ncsa': }

## Tests
   For more examples check module tests directory.  
   NOTE: make sure you don't run tests on Production server.  

## Development
  Contributions and patches are welcome!  
  All new code goes into branch develop.  

## Contributors
- Max Horlanchuk <max.horlanchuk@gmail.com>
- Fabio Rauber <fabiorauber@gmail.com>
- Samuel Leathers <sam@appliedtrust.com>
- Lienhart Woitok <lienhart.woitok@netlogix.de>
- Adrian Webb <adrian.webb@coraltech.net>
- Frode Egeland <egeland@gmail.com>
- Matt Ward <matt.ward@envato.com>
- Noel Sharpe <noels@radnetwork.co.uk>
- Rich Kang <rich@saekang.co.uk>
- browarrek <browarrek@gmail.com>
