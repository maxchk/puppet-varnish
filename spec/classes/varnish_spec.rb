require 'spec_helper'

describe 'varnish', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistid              => 'Debian',
        :lsbdistcodename        => 'precise'
      }
    end
    
    it { should compile }
    it { should contain_class('varnish::install').with('add_repo' => 'true') }
    it { should contain_class('varnish::service').with('start' => 'yes') }
    it { should contain_class('varnish::shmlog') }
    it { should contain_file('varnish-conf').with(
      'ensure'  => 'present',
      'path'    => '/etc/default/varnish',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[varnish]',
      'notify'  => 'Service[varnish]'
      )
    }
    it { should contain_file('storage-dir').with(
      'ensure'  => 'directory',
      'path'   => '/var/lib/varnish-storage',
      'require' => 'Package[varnish]'
      )
    }
    
    context "without shmlog_tempfs" do
      let :params do
        { :shmlog_tempfs => false }
      end

      it { should_not contain_class('varnish::shmlog') }
    end
    
    context "default varnish-conf values" do
      it { should contain_file('varnish-conf').with_content(/START=yes/) }
      it { should contain_file('varnish-conf').with_content(/NFILES=131072/) }
      it { should contain_file('varnish-conf').with_content(/MEMLOCK=82000/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_VCL_CONF=\/etc\/varnish\/default\.vcl/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_LISTEN_ADDRESS=/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_LISTEN_PORT=6081/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_ADMIN_LISTEN_ADDRESS=127.0.0.1/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_ADMIN_LISTEN_PORT=6082/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_MIN_THREADS=5/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_MAX_THREADS=500/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_THREAD_TIMEOUT=300/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_STORAGE_FILE=\/var\/lib\/varnish-storage\/varnish_storage\.bin/) }    
      it { should contain_file('varnish-conf').with_content(/VARNISH_STORAGE_SIZE=1G/) }    
      it { should contain_file('varnish-conf').with_content(/VARNISH_SECRET_FILE=\/etc\/varnish\/secret/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_STORAGE=\"malloc,\${VARNISH_STORAGE_SIZE}\"/) }
      it { should contain_file('varnish-conf').with_content(/VARNISH_TTL=120/) }
      it { should contain_file('varnish-conf').with_content(/DAEMON_OPTS=\"-a \${VARNISH_LISTEN_ADDRESS}:\${VARNISH_LISTEN_PORT}/) }

    end
  end

  context "on a RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :concat_basedir  => '/dne',
        :operatingsystem => 'RedHat'
      }
    end
    
    it { should compile }
    it { should contain_class('varnish::install').with('add_repo' => 'true') }
    it { should contain_class('varnish::service').with('start' => 'yes') }
    it { should contain_class('varnish::shmlog') }
    it { should contain_file('varnish-conf').with(
      'ensure'  => 'present',
      'path'    => '/etc/sysconfig/varnish',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[varnish]',
      'notify'  => 'Service[varnish]'
      )
    }
    it { should contain_file('storage-dir').with(
      'ensure'  => 'directory',
      'path'   => '/var/lib/varnish-storage',
      'require' => 'Package[varnish]'
      )
    }
    context "without shmlog_tempfs" do
      let :params do
        { :shmlog_tempfs => false }
      end

      it { should_not contain_class('varnish::shmlog') }
    end
  end
end
