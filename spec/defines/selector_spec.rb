require 'spec_helper'

describe 'varnish::selector', :type => :define do
  let(:facts) do
    {
      architecture: 'x86_64',
      lsbdistcodename: 'xenial',
      lsbdistid: 'Debian',
      operatingsystem: 'Ubuntu',
      operatingsystemmajrelease: '16.04',
      operatingsystemrelease: '16.04',
      osfamily: 'Debian',
      puppetversion: Puppet.version,
      selinux: false,
      init_system: 'systemd',
    }
  end
  let(:pre_condition) do
    [
      "class { 'varnish': version => #{varnish_version.to_s.to_json} }",
      'include varnish::vcl',
    ]
  end

  let(:title) { 'foobar' }
  let(:params) do
    {
      condition: 'req.http.Host == "www.foobar.com"'
    }
  end
  let(:varnish_version) { 5.0 }

  context 'with varnish::version => 3.0' do
    let(:varnish_version) { 3.0 }

    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_concat__fragment("#{title}-selector")
        .that_notifies('Service[varnish]')
        .with(
          target: '/etc/varnish/includes/backendselection.vcl',
          order: 10,
        )
    end

    context 'with director' do
      it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.backend = #{Regexp.escape title};$/) }
    end
  end

  context 'with varnish::version => 4.1' do
    let(:varnish_version) { 4.1 }

    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_concat__fragment("#{title}-selector")
        .that_notifies('Service[varnish]')
        .with(
          target: '/etc/varnish/includes/backendselection.vcl',
          order: 10,
        )
    end

    context 'with backend' do
      let(:params) { super().merge(:backend => 'backend01') }

      it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.backend_hint = #{Regexp.escape params[:backend]};$/) }
    end

    context 'with director' do
      it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.backend_hint = #{Regexp.escape title}\.backend\(\);$/) }
    end
  end

  context 'with varnish::version => 5.0' do
    let(:varnish_version) { 5.0 }

    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_concat__fragment("#{title}-selector")
        .that_notifies('Service[varnish]')
        .with(
          target: '/etc/varnish/includes/backendselection.vcl',
          order: 10,
        )
    end

    context 'with backend' do
      let(:params) { super().merge(:backend => 'backend01') }

      it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.backend_hint = #{Regexp.escape params[:backend]};$/) }
    end

    context 'with director' do
      it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.backend_hint = #{Regexp.escape title}\.backend\(\);$/) }
    end
  end

  context 'with rewrite' do
    let(:params) { super().merge(:rewrite => '"foobar.com"') }

    it { is_expected.to contain_concat__fragment("#{title}-selector").with_content(/^  set req\.http\.x-host = #{Regexp.escape params[:rewrite]};$/) }
  end

  context 'with order' do
    let(:params) { super().merge(:order => 20) }

    it { is_expected.to contain_concat__fragment("#{title}-selector").with_order(params[:order]) }
  end
end
