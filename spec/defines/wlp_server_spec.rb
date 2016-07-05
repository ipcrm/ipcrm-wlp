require 'spec_helper'

describe 'wlp::server', :type => :define do
  let(:pre_condition) { 'class {"::wlp": install_src => "/tmp/wlp-javaee7-16.0.0.2.zip"}' }
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let :title do
          'testserver'
        end

        context "wlp::server class with user and base dir  set" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_wlp_server('testserver').with({ :base_path => '/opt/ibm/wlp', :ensure => 'present' }) }
          it { is_expected.to contain_wlp_server_control('testserver').with({ :base_path => '/opt/ibm/wlp', :ensure => 'running' }) }
        end

        context "wlp::server class with user and base dir  set; but disabled" do
          let(:params) { { :enable => false } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_wlp_server('testserver').with({ :base_path => '/opt/ibm/wlp', :ensure => 'present' }) }
          it { is_expected.to contain_wlp_server_control('testserver').with({ :base_path => '/opt/ibm/wlp', :ensure => 'stopped' }) }
        end

        context "wlp::server class with user and base dir set; but configured to absent" do
          let(:params) { { :ensure => 'absent' } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_wlp_server('testserver').with({ :base_path => '/opt/ibm/wlp', :ensure => 'absent' }) }
          it { should_not contain_wlp_server_control('testserver') }
        end

      end
    end
  end
end
