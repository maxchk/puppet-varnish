## Varnish module - install, configure and manage VCL (Ubuntu/CentOS)

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

## Usage, class varnish

   installs Varnish  
   allocates for cache 1GB (malloc)  
   starts it on port 80:  

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

## Class varnish::vcl

   Manages Varnish VCL configuration.  
   In most cases Varnish default configuration will run just fine.  
   The only thing to configure are backends, directors and probes.  

   VCL applies following restictions:  
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
      cluster2 => { condition => 'req.url ~ "^/cluster2"' },
      cluster1 => { },
    },

Will result in following VCL configuration to be generated:

    if (req.url ~ "^/cluster2") {
      set req.backend = cluster2;
    } else {
      set req.backend = cluster1;
    }

`conditions` - TODO.

If modification to Varnish VCL goes further than configuring `probes`, `backends` and `directors`
parameter `template` can be used to point `varnish::vcl` class at a different template.

NOTE: If you copy existing template and modify it you will still 
be able to use `probes`, `backends`, `directors` and `selectors` parameters.

## Usage, class varnish::vcl

   Simple setup:  
   1 probe  
   2 backends  
   1 director  

    class { 'varnish::vcl':
      probes => {
        health_check => { url => "/health_check" },
      },
      backends => {
        server1 => { host => '192.168.1.1', port => '80', probe => 'health_check' },
        server2 => { host => '192.168.1.2', port => '80', probe => 'health_check' },
      },
      directors => {
        cluster => { type => 'round-robin', backends => [ 'server1', 'server2' ] }
      },
      selectors => {
        cluster => { },
      },
    }


   Slightly more complex setup:  
   2 probes  
   8 backends  
   2 directors  
   traffic for URL /cluster2 goes to second director 'cluster2'

    class { 'varnish::vcl':
      probes => {
        health_check1 => {
          window    => '8',
          timeout   => '5s',
          threshold => '3',
          interval  => '5s',
          request   => [ "GET /action/healthCheck1 HTTP/1.1", "Host: www.example1.com", "Connection: close" ],
        },
        health_check2 => {
          window    => '8',
          timeout   => '5s',
          threshold => '3',
          interval  => '5s',
          request   => [ "GET /action/healthCheck2 HTTP/1.1", "Host: www.example2.com", "Connection: close" ],
        },
      },
      backends => {
        server1 => { host => '192.168.1.21', port => '80', probe => 'health_check1' },
        server2 => { host => '192.168.1.22', port => '80', probe => 'health_check1' },
        server3 => { host => '192.168.1.23', port => '80', probe => 'health_check1' },
        server4 => { host => '192.168.1.24', port => '80', probe => 'health_check1' },
        server5 => { host => '192.168.1.25', port => '80', probe => 'health_check1' },
        server6 => { host => '192.168.1.26', port => '80', probe => 'health_check1' },
        server7 => { host => '192.168.1.27', port => '80', probe => 'health_check2' },
        server8 => { host => '192.168.1.28', port => '80', probe => 'health_check2' },
      },
      directors => {
        cluster1 => {
          backends => [ 'server1', 'server2', 'server3', 'server4', 'server5', 'server6' ],
         },
        cluster2 => {
          backends => [ 'server7', 'server8' ],
        },
      },
      selectors => {
        cluster2 => { condition => 'req.url ~ "^/cluster2"' },
        cluster1 => { },
      },
    }

## Tests
   For more examples check module tests directory.  
   NOTE: make sure you don't run tests on Production server.  

## Development
  Contributions and patches are welcome!  
  All new code goes into branch develop.  
