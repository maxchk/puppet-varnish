# Varnish module - install, configure and manage VCL (Ubuntu/CentOS)

This module install, configure and manage Varnish VCL.
Tested on Ubuntu and CentOS.

# Usage

Install Varnish, allocate for cache 1GB (malloc) and start it on port 80:

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

Do the same, plus add some backend configuration:

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

    class { 'varnish::vcl':
      probes => [
        { name => 'health_check', url => "/health_check" },
      ],
      backends => [
        { name => 'server1', host => '192.168.1.1', port => '80', probe => 'health_check' },
        { name => 'server2', host => '192.168.1.2', port => '80', probe => 'health_check' },
      ],
      directors => [
        { name => 'cluster', type => 'round-robin', backends => [ 'server1', 'server2' ] }
      ],
      selectors => [
        { backend => 'cluster' },
      ],
    }


For more examples check module tests directory.
NOTE: make sure you don't run tests on Production server.
