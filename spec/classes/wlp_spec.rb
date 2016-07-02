require 'spec_helper'

describe 'wlp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "wlp class with install_src set" do
          let(:params) { {:install_src => '/tmp/wlp-javaee7-16.0.0.2.zip' } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('wlp') }
          it { is_expected.to contain_class('wlp::params') }
          it { is_expected.to contain_class('java') }
          it { is_expected.to contain_archive('wlp-javaee7-16.0.0.2.zip').with({ 'extract_path' => '/opt/ibm' }) }
          it { is_expected.to contain_user('wlp').with({ 'home' => '/opt/ibm' }) }
          it { is_expected.to contain_file('/opt/ibm').with({ 'ensure' => 'directory', 'owner' => 'wlp', 'group' => 'wlp', 'mode' => '0755' }) }
          it { is_expected.to contain_file('/usr/local/wlp').with({ 'ensure' => 'link', 'target' => '/opt/ibm/wlp' }) }
          it { is_expected.to contain_file('/opt/ibm/wlp/bin').with({ 'ensure' => 'directory', 'owner' => 'wlp', 'group' => 'wlp', 'mode' => '0750', 'recurse' => 'true' }) }
        end

        context "wlp class with overriden location and user parameter" do
          let(:params) { {:base_dir => '/usr/local/wlp_test', :wlp_user => 'ibm', :install_src => '/tmp/wlp-javaee7-16.0.0.2.zip' } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('wlp') }
          it { is_expected.to contain_class('wlp::params') }
          it { is_expected.to contain_class('java') }
          it { is_expected.to contain_archive('wlp-javaee7-16.0.0.2.zip').with({ 'extract_path' => '/usr/local/wlp_test' }) }
          it { is_expected.to contain_user('ibm').with({ 'home' => '/usr/local/wlp_test' }) }
          it { is_expected.to contain_file('/usr/local/wlp_test').with({ 'ensure' => 'directory', 'owner' => 'ibm', 'group' => 'ibm', 'mode' => '0755' }) }
          it { is_expected.to contain_file('/usr/local/wlp').with({ 'ensure' => 'link', 'target' => '/usr/local/wlp_test/wlp' }) }
          it { is_expected.to contain_file('/usr/local/wlp_test/wlp/bin').with({ 'ensure' => 'directory', 'owner' => 'ibm', 'group' => 'ibm', 'mode' => '0750', 'recurse' => 'true' }) }
        end

        context "wlp class with overriden manage java and user parameter" do
          let(:params) { {:manage_user => false, :manage_java => false, :install_src => '/tmp/wlp-javaee7-16.0.0.2.zip' } }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('wlp') }
          it { is_expected.to contain_class('wlp::params') }
          it { is_expected.to contain_class('wlp::params') }
          it { is_expected.to contain_archive('wlp-javaee7-16.0.0.2.zip').with({ 'extract_path' => '/opt/ibm' }) }
          it { should_not contain_class('java') }
          it { should_not contain_user('wlp') }
          it { is_expected.to contain_file('/opt/ibm').with({ 'ensure' => 'directory', 'owner' => 'wlp', 'group' => 'wlp', 'mode' => '0755' }) }
          it { is_expected.to contain_file('/usr/local/wlp').with({ 'ensure' => 'link', 'target' => '/opt/ibm/wlp' }) }
          it { is_expected.to contain_file('/opt/ibm/wlp/bin').with({ 'ensure' => 'directory', 'owner' => 'wlp', 'group' => 'wlp', 'mode' => '0750', 'recurse' => 'true' }) }
        end
      end
    end
  end
end
