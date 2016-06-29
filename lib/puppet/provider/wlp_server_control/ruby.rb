Puppet::Type.type(:wlp_server_control).provide(:ruby) do

  def get_base_path
    base_path = '/usr/local/wlp'
    server_command = "#{base_path}/bin/server"
    if File.directory?(base_path)
      server_command
    else
        raise Puppet::Error, "Cannot find installation path (symlink) #{base_path}"
    end

  end

  def start(server)
    Puppet::Util::Execution.execute([ get_base_path, :start, server].flatten,
                                    :uid => resource[:wlp_user],
                                    :combine => true,
                                    :failonfail => false
                                    )
  end

  def stop(server)
    Puppet::Util::Execution.execute([ get_base_path, :stop, server].flatten,
                                    :uid => resource[:wlp_user],
                                    :combine => true,
                                    :failonfail => false
                                    )
  end

  def state
    output = Puppet::Util::Execution.execute([ get_base_path, :status, resource[:name]].flatten,
                                             :uid => resource[:wlp_user],
                                             :combine => true,
                                             :failonfail => false,
                                            )
    case output.exitstatus
    when 2
      raise Puppet::Error, "Server #{resource[:name]} does not exist!"
    when 1
      :stopped
    when 0
      :running
    end
  end

  def restart
    if state == :running
      stop(resource[:name])
      start(resource[:name])
    else
      start(resource[:name])
    end
  end

  def ensure
    state
  end

  def ensure=(value)
    if value == :running
      start(resource[:name])
    else
      stop(resource[:name])
    end
  end
end
