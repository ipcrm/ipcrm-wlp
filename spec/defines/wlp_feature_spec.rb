require 'spec_helper'

describe 'wlp::feature', :type => :define do
 let(:pre_condition){
   '
    class {"wlp": install_src => "https://public.dhe.ibm.com/downloads/wlp/16.0.0.2/wlp-javaee7-16.0.0.2.zip" }
   '
 }
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let :title do
          'openidConnectClient-1.0'
        end

        context "wlp::feature install openidConnectClient-1.0" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_wlp_feature('openidConnectClient-1.0').with({
            :ensure    => 'present',
            :base_path => '/opt/ibm/wlp',
            :wlp_user  => 'wlp',
          }) }
        end

      end
    end
  end
end
