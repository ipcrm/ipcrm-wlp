Puppet::Type.type(:wlp_server).provide(:ruby) do

  mk_resource_methods

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

  def self.get_configured_servers
    base_path = get_base_path
    begin
      server_command = "#{base_path}/bin/server"
      command = [server_command, 'list']
      configured_servers = Puppet::Util::Execution.execute(command, :combine => false, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("get_configured_servers failed to generate list -> #{e.inspect}")
      return nil
    end

    return nil if configured_servers.nil?
    configured_servers.split("\n").delete_if{|s| s =~ /^$/}.slice(1..configured_servers.size)
  end

  def self.instances
    instances = []
    get_configured_servers.collect do |s|
      instances << new({ :ensure => :present, :provider => :ruby, :name => s })
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

  def configure_server
    base_path = self.class.get_base_path
    server_command = "#{base_path}/bin/server"
    arguments = Array.new

    if @property_flush[:ensure] == :absent
      arguments = ['stop',"#{resource[:name]}"]
      command = arguments.unshift(server_command).flatten.uniq
      Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => false)

      begin
        server_path = "#{base_path}/usr/servers/#{resource[:name]}"
        if File.directory?(server_path)
          self.debug "Deleting server at #{server_path}"
          FileUtils.remove_entry_secure(server_path)
        else
          raise Puppet::Error, "Cannot find requested server at path #{server_path}"
        end
      rescue Errno::ENOENT => e
        raise Puppet::Error, "Failed to remove server at path #{server_path}, #{e.message}"
      end
    elsif @property_flush[:ensure] == :present
      arguments.push('create')
      arguments.push(resource[:name])
      arguments.push("--template=#{resource[:template]}")  if resource[:template]
      arguments.push("--include=#{resource[:include]}")    if resource[:include]
      command = arguments.unshift(server_command).flatten
      Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
    end

  end

  def flush
    configure_server
    if self.class.get_configured_servers.include?(resource[:name])
      @property_hash = { :ensure => :present, :provider => :ruby, :name => resource[:name] }
    else
      @property_hash = { :ensure => :absent, :provider => :ruby, :name => resource[:name] }
    end
  end
end
