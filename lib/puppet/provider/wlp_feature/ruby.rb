Puppet::Type.type(:wlp_feature).provide(:ruby) do

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_base_path
    base_path = '/usr/local/wlp'
    if File.directory?(base_path)
      return base_path
    else
        raise Puppet::Error, "Cannot find installation path (symlink) #{base_path}"
    end
  end

  def self.get_installed_features
    base_path = get_base_path
    begin
      feature_command = "#{base_path}/bin/productInfo"
      command = [feature_command, 'featureInfo']
      installed_features = Puppet::Util::Execution.execute(command, :combine => true, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("get_installed_features failed to generate report -> #{e.inspect}")
      return nil
    end

    return nil if installed_features.empty?

    features = Array.new
    installed_features.split(/\n/).each do |f|
      features.push(f.split(' ')[0])
    end

    features
  end

  def self.instances
    features = get_installed_features
    instances = []
      features.collect do |f|
        f_new            = {}
        f_new[:ensure]   = :present
        f_new[:provider] = :ruby
        f_new[:name]     = f
        instances << new(f_new)
      end

    instances
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def configure_feature
    base_path = self.class.get_base_path
    installutility = "#{base_path}/bin/installUtility"
    arguments = Array.new
    if @property_flush[:ensure] == :absent
      arguments = ['uninstall','--verbose','--noPrompts',"#{resource[:name]}"]
    else
      arguments.push('install')
      arguments.push(resource[:name])
      arguments.push('--acceptLicense')                   if resource[:accept_license] == :true
      arguments.push('--to=extension')                    if resource[:install_type] == 'extension'
      arguments.push("--from=#{resource[:install_from]}") if resource[:install_from]
      arguments.push("--downloadDependencies=false")      if resource[:download_deps] != :true
      arguments.push("--verbose")                         if resource[:verbose] == :true
    end

    command = arguments.unshift(installutility).flatten
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def flush
    configure_feature
    if self.class.get_installed_features.include?(resource[:name])
      @property_hash = { :ensure => :present, :provider => :ruby, :name => resource[:name] }
    end
  end
end
