Puppet::Type.newtype(:wlp_server) do
  desc "Puppet type for configuring IBM Websphere Liberty servers"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Server name to configure"
    newvalues(/^[a-zA-Z0-9_]*$/)
  end

  newparam(:template) do
    desc "Optional.  Specify the template to use for setting up the new server"
    newvalues(/^[a-zA-Z0-9_]*$/)
  end

  newparam(:include) do
    desc "A comma-delimited list of values. The valid values vary depending on the action."
    newvalues(/^[a-zA-Z0-9_,=]*$/)
  end

  newparam(:verbose) do
    desc "Enable verbose output"
    newvalues(:true, :false)
  end

  newproperty(:state) do
    desc "Set the server state, running or stopped"
    newvalues(:running, :stopped)
  end

  newparam(:base_path) do
    desc "Installation path for WLP"
    validate do |value|
      if value.nil?
        raise ArgumentError, "Base path must be an absolute path: #{value}"
      end
    end
  end

  newparam(:wlp_user) do
    desc "user that WLP is installed/running as"
    validate do |value|
      if value.nil?
        raise ArgumentError, "WLP user must be provided!"
      end
    end
  end

end
