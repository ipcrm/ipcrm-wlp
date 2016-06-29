Puppet::Type.newtype(:wlp_server_control) do
  desc "Puppet type for controlling state of a Websphere Liberty Profile (ie running/stopped)"

  newparam(:name, :namevar => true) do
    desc "Server name to configure"
    newvalues(/^[a-zA-Z0-9_]*$/)
  end

  newproperty(:ensure) do
    desc "Set the state of server, running or stopped"
    newvalues(:running, :stopped)
  end

  newparam(:base_path) do
    desc "Installation path for WLP"
  end

  newparam(:wlp_user) do
    desc "user that WLP is installed/running as"
  end

  validate do
    [:base_path,:wlp_user].each do |p|
      if parameters[p].nil?
        raise ArgumentError, "Parameter #{p} must be provided!"
      end
    end
  end

  autorequire(:wlp_server) do
    self[:name]
  end

  def refresh
    provider.restart
  end

end
