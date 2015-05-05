require 'spec_helper'

describe 'varnish::shmlog', :type => :class do
  context "default values" do

    it { should compile }
    it { should contain_file('shmlog-dir').with(
      'ensure' => 'directory',
       'path'  => '/var/lib/varnish'
      )
    }
    it { should contain_mount('shmlog-mount').with(
        'target'  => '/etc/fstab',
        'fstype'  => 'tmpfs',
        'device'  => 'tmpfs',
        'options' => 'defaults,noatime,size=128M'
      )
    }

  end
  
  context "default values" do
    
  end

end