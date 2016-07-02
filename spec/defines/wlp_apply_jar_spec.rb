require 'spec_helper'

describe 'wlp::apply_jar', :type => :define do
 let(:pre_condition) { 'class {"::wlp": install_src => "/tmp/wlp-javaee7-16.0.0.2.zip"}' }
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let :title do
          '/var/tmp/wlp-extended-16.0.0.2.jar'
        end

        context "wlp::apply_jar class with user and base dir set" do
          let(:params) { { :user => 'wlp', :base_path => '/opt/ibm/wlp', :creates => 'lib/features/wss4j-1.0.mf' } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_archive('wlp-extended-16.0.0.2.jar').with({
            :path   => '/opt/ibm/wlp/wlp-extended-16.0.0.2.jar',
            :source => '/var/tmp/wlp-extended-16.0.0.2.jar',
            :user   => 'wlp',
            :group  => 'wlp'
          }) }
          it { is_expected.to contain_exec('extract-wlp-extended-16.0.0.2.jar').with({
            :command   => 'java -jar /opt/ibm/wlp/wlp-extended-16.0.0.2.jar --acceptLicense /opt/ibm/wlp',
            :unless    => 'test -e /opt/ibm/wlp/lib/features/wss4j-1.0.mf',
            :logoutput => true,
          }) }
        end
      end
    end
  end
end
