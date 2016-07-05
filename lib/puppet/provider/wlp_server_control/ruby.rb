Puppet::Type.type(:wlp_server_control).provide(:ruby) do

  def get_base_path
    server_command = "#{resource[:base_path]}/bin/server"
    if File.exists?(server_command)
      server_command
    else
        raise Puppet::Error, "Cannot find server command at path #{server_command}"
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
    if resource[:ensure] == :running
      if state == :running
        stop(resource[:name])
        start(resource[:name])
      else
        start(resource[:name])
      end
    else
      Puppet.debug("Server #{resource[:name]} not currently running - requested state is #{resource[:ensure]}, skipping refresh")
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
