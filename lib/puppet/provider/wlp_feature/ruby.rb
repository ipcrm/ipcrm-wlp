Puppet::Type.type(:wlp_feature).provide(:ruby) do
  require 'rexml/document'
  include REXML

  def get_installed_features
    xml_report="#{resource[:base_path]}/features.xml"
    begin
      featuremanager = "#{@resource[:base_path]}/bin/featureManager"
      command = [featuremanager, 'featureList', xml_report]
      Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("get_installed_features failed to generate xml report -> #{e.inspect}")
      return nil
    end

    installed_features = Array.new
    install_report = REXML::Document.new(File.read(xml_report))
    REXML::XPath.each( install_report, "//feature") { |f| installed_features.push(f.attributes['name']) }

    return nil if installed_features.empty?
    installed_features
  end

  def exists?
    get_installed_features.include?(resource[:name])
  end

  def create
    installutility = "#{@resource[:base_path]}/bin/installUtility"

    arguments = Array.new
    arguments.push(resource[:name])

    if resource[:accept_license] == :true
      arguments.push('--acceptLicense')
    end

    if resource[:install_type] == 'extension'
      arguments.push('--to=extension')
    end

    if resource[:install_from]
      arguments.push("--from=#{resource[:install_from]}")
    end

    if resource[:download_deps] != :true
      arguments.push("--downloadDependencies=false")
    end

    if resource[:verbose] == :true
      arguments.push("--verbose")
    end

    command = arguments.unshift('install').flatten.uniq
    command = arguments.unshift(installutility).flatten.uniq
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def destroy
    installutility = "#{@resource[:base_path]}/bin/installUtility"

    arguments = ['uninstall','--verbose','--noPrompts',"#{resource[:name]}"]
    command = arguments.unshift(installutility).flatten.uniq

    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end


end
