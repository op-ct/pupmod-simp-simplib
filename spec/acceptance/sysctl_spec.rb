require 'spec_helper_acceptance'

test_name 'simplib::sysctl class'

describe 'simplib::sysctl class' do
  let(:disable_ipv6_hieradata) {{
    'simplib::sysctl::enable_ipv6' => false
  }}

  let(:manifest) {
    <<-EOS
      include 'simplib::sysctl'
    EOS
  }

  hosts.each do |host|
    context 'default parameters' do

      it 'should apply sysctl with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'sysctl should enable ipv6 by default' do
        result = on(host,"sysctl -n net.ipv6.conf.all.disable_ipv6")
        expect(result.output.strip).to eq('0')
      end

    end

    context 'sysctl with enable ipv6 = false' do

      it 'set hieradata' do
        set_hieradata_on(host, disable_ipv6_hieradata)
      end

      it 'set ipv6_enable = true' do
        on(host, "sysctl net.ipv6.conf.all.disable_ipv6=0")
      end

      it 'should apply simplib::sysctl with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'sysctl should disable ipv6' do
        result = on(host,"sysctl -n net.ipv6.conf.all.disable_ipv6")
        expect(result.output.strip).to eq('1')
      end
    end
  end
end
