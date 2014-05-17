require 'spec_helper'

describe 'varnish::service', :type => :class do
  context "on a Debian OS family" do
    let :facts do
      {
        :osfamily        => 'Debian',
        :lsbdistid       => 'Debian',
        :operatingsystem => 'Debian',
        :lsbdistcodename => 'foo'
      }
    end

    it { should compile }
    it { should contain_class('varnish::install') }
      
    it { should contain_service('varnish').with(
      'ensure'  => 'running',
      'restart' => '/etc/init.d/varnish reload',
      'require' => 'Package[varnish]'
      ) 
    }
  end

  context "on a RedHat OS family and sisabled" do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end
    
    let(:params) { { :start => 'no' } }

    it { should compile }
    it { should contain_class('varnish::install') }
      
    it { should contain_service('varnish').with(
      'ensure'  => 'stopped',
      'restart' => '/sbin/service varnish reload',
      'require' => 'Package[varnish]'
      ) 
    }
  end  
end