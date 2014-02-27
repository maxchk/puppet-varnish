##Table of Contents
1. [Varnish module - install, configure and manage VCL](#overview)
2. [Class varnish](#class-varnish)
3. [Setup Varnish](#setup-varnish)
4. [Class varnish::vcl](#class-varnish::vcl)
5. [Using class varnish::vcl](#using-class-varnish::vcl)
6. [Tests](#tests)
7. [Development](#development)

## Overview

   This Puppet module installs and configures Varnish.  
   It also allows to manage Varnish VCL.  
   Tested on Ubuntu, CentOS, RHEL and Oracle Linux.

## Class varnish

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

## Setup Varnish

   installs Varnish  
   allocates for cache 1GB (malloc)  
   starts it on port 80:  

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

## Class varnish::vcl

   Manages Varnish VCL configuration.  
   NOTE: though you can pass config for backends, directors, acls, probes and selectors  
         as parameters to this class, it is recommended to use existing definitions instead:  

    varnish::backend
    varnish::director
    varnish::probe
    varnish::acl
    varnish::selector

   In most cases Varnish default configuration will run just fine.  
   The only thing to configure are backends, directors and probes.  

   VCL applies following restictions:  
   if you define an acl it must be used  
   if you define a probe it must be used  
   if you define a backend it must be used  
   if you define a director it must be used  

   varnish::vcl accepts following parameters:  
   `acls`  
   `probes`  
   `backends`  
   `directors`  
   `selectors`  
   `conditions`  
   `template`  

   While `acls`, `probes`, `backends` and `directors` are self-explanatory and `template` is guessable  
   WTF are `selectors` and `conditions`?  

   You cannot define 2 or more backends/directors and not to use them.  
   This will result in VCL compilation failure.  

   Parameter `selectors` gives access to req.backend inside vcl_recv.  
   Code:  

    selectors => {
      'cluster1' => { condition => 'req.url ~ "^/cluster1"' },
      'cluster2' => { condition => 'true' } # will act as backend set by else statement
    }

Will result in following VCL configuration to be generated:

    if (false) { 
    } elsif (req.url ~ "^/cluster1") {
      set req.backend = cluster1;
    } elsif (true) {
      set req.backend = cluster2;
    } else { 
      error 403 "Access denied"; 
    }


`conditions` - TODO.

If modification to Varnish VCL goes further than configuring `probes`, `backends` and `directors`
parameter `template` can be used to point `varnish::vcl` class at a different template.

NOTE: If you copy existing template and modify it you will still 
be able to use `probes`, `backends`, `directors` and `selectors` parameters.

## Usaging class varnish::vcl

   Configure probes, backends, directors and selectors  
   by passing parameters to class 

    class { 'varnish::vcl':

      # configure probes
      probes => {
        'health_check1' => { url => '/health_check_url1' },
        'health_check2' => { 
          window    => '8',
          timeout   => '5s',
          threshold => '3',
          interval  => '5s',
          request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
        }
      },

      # configure backends
      backends => { 
        'srv1' => { host => '172.16.0.1', port => '80', probe => 'health_check1' },
        'srv2' => { host => '172.16.0.2', port => '80', probe => 'health_check1' },
        'srv3' => { host => '172.16.0.3', port => '80', probe => 'health_check2' },
        'srv4' => { host => '172.16.0.4', port => '80', probe => 'health_check2' },
        'srv5' => { host => '172.16.0.5', port => '80', probe => 'health_check2' },
        'srv6' => { host => '172.16.0.6', port => '80', probe => 'health_check2' },
      }, 

      # configure directors
      directors => {
        'cluster1' => { backends => [ 'srv1', 'srv2' ] },
        'cluster2' => { backends => [ 'srv3', 'srv4', 'srv5', 'srv6' ] }
      },

      # configure selectors
      selectors => {
        'cluster1' => { condition => 'req.url ~ "^/cluster1"' },
        'cluster2' => { condition => 'true' }
      }
    }

   Same as above by using definitions  

    class { 'varnish::vcl': }

    # configure probes
    varnish::probe { 'health_check1': url => '/health_check_url1' }
    varnish::probe { 'health_check2':  
      window    => '8',
      timeout   => '5s',
      threshold => '3',
      interval  => '5s',
      request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
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

## Tests
   For more examples check module tests directory.  
   NOTE: make sure you don't run tests on Production server.  

## Development
  Contributions and patches are welcome!  
  All new code goes into branch develop.  
