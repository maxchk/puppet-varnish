require 'spec_helper'

describe 'varnish::acl', :type => :define do
  let :pre_condition do
    'class { "::varnish::vcl": }'
  end
    
  let(:title) { 'foo' }
  let(:facts) { { :concat_basedir => '/dne' } }
  
  context("expected behaviour") do
    let(:params) { { :hosts => ['192.168.10.14'] } }
    it { should contain_file('/etc/varnish/includes/acls.vcl') }
    it { should contain_concat__fragment('foo-acl') }
  end
  
  context("invalid acl title") do
    let(:title) { '-wrong_title' }

    it 'should cause a failure' do
      expect {should raise_error(Puppet::Error, 'Invalid characters in ACL name _wrong-title. Only letters, numbers and underscore are allowed.') }
    end    
  end

end
