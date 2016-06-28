Puppet::Type.type(:wlp_feature).provide(:ruby) do

  def get_base_path
    base_path = '/usr/local/wlp'
    if File.directory?(base_path)
      return base_path
    else
        raise Puppet::Error, "Cannot find installation path (symlink) #{base_path}"
    end
  end

  def get_installed_features
    base_path = get_base_path
    begin
      feature_command = "#{base_path}/bin/productInfo"
      command = [feature_command, 'featureInfo']
      installed_features = Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("get_installed_features failed to generate report -> #{e.inspect}")
      return nil
    end

    return nil if installed_features.empty?
    installed_features
  end

  def exists?
    get_installed_features.include?(resource[:name])
  end

  def create
    base_path = self.class.get_base_path
    installutility = "#{base_path}/bin/installUtility"

    arguments = Array.new
    arguments.push(resource[:name])
    arguments.push('--acceptLicense')                   if resource[:accept_license] == :true
    arguments.push('--to=extension')                    if resource[:install_type] == 'extension'
    arguments.push("--from=#{resource[:install_from]}") if resource[:install_from]
    arguments.push("--downloadDependencies=false")      if resource[:download_deps] != :true
    arguments.push("--verbose")                         if resource[:verbose] == :true

    command = arguments.unshift('install')
    command = arguments.unshift(installutility).flatten
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def destroy
    base_path = self.class.get_base_path
    installutility = "#{base_path}/bin/installUtility"

    arguments = ['uninstall','--verbose','--noPrompts',"#{resource[:name]}"]
    command = arguments.unshift(installutility).flatten.uniq

    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end


end
