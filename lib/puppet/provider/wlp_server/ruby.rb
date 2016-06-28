Puppet::Type.type(:wlp_server).provide(:ruby) do

  def get_base_path
    base_path = '/usr/local/wlp'
    if File.directory?(base_path)
      return base_path
    else
        raise Puppet::Error, "Cannot find installation path (symlink) #{base_path}"
    end
  end

  def get_configured_servers
    base_path = get_base_path
    begin
      server_command = "#{base_path}/bin/server"
      command = [server_command, 'list']
      configured_servers = Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("get_configured_servers failed to generate list -> #{e.inspect}")
      return nil
    end

    return nil if configured_servers.nil?
    configured_servers
  end

  def exists?
    servers = get_configured_servers
    servers.include?(resource[:name])
  end

  def create
    base_path = self.class.get_base_path
    server_command = "#{base_path}/bin/server"

    arguments = Array.new
    arguments.push(resource[:name])
    arguments.push("--template=#{resource[:template]}")                    if resource[:template]
    arguments.push("--include=#{resource[:include]}")                    if resource[:include]

    command = arguments.unshift('create')
    command = arguments.unshift(server_command).flatten
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def state
    base_path = get_base_path
    server_command = "#{base_path}/bin/server"
    command = [server_command, 'status', resource[:name]].flatten
    output = Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => false)

    if output.include?('is running')
      return 'running'
    else
      return 'stopped'
    end
  end

  def state=(value)
    base_path = get_base_path
    server_command = "#{base_path}/bin/server"

    arg = value == :running ? 'start' : 'stop'

    command = [server_command, arg, resource[:name]].flatten
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def destroy
    base_path = self.class.get_base_path
    server_command = "#{base_path}/bin/server"

    arguments = ['stop',"#{resource[:name]}"]
    command = arguments.unshift(server_command).flatten.uniq
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => false)

    begin
      server_path = "#{base_path}/usr/servers/#{resource[:name]}"
      if File.directory?(server_path)
        FileUtils.remove_entry_secure(server_path)
      else
        raise Puppet::DevError, "Cannot find requested server at path #{server_path}"
      end
    rescue Errno::ENOENT => e
      raise Puppet::Error, "Failed to remove server at path #{server_path}, #{e.message}"
    end
  end
end
