Puppet::Type.type(:wlp_server).provide(:ruby) do
  def get_configured_servers
    begin
      server_command = "#{@resource[:base_path]}/bin/server"
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
    server_command = "#{resource[:base_path]}/bin/server"

    arguments = Array.new
    arguments.push(resource[:name])
    arguments.push("--template=#{resource[:template]}")                    if resource[:template]
    arguments.push("--include=#{resource[:include]}")                    if resource[:include]

    command = arguments.unshift('create')
    command = arguments.unshift(server_command).flatten
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => true)
  end

  def destroy
    server_command = "#{resource[:base_path]}/bin/server"

    arguments = ['stop',"#{resource[:name]}"]
    command = arguments.unshift(server_command).flatten.uniq
    Puppet::Util::Execution.execute(command, :uid => resource[:wlp_user], :combine => true, :failonfail => false)

    begin
      server_path = "#{resource[:base_path]}/usr/servers/#{resource[:name]}"
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
