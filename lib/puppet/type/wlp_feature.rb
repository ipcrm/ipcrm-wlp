Puppet::Type.newtype(:wlp_feature) do
  desc "Puppet type for installing IBM Websphere Liberty features"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Feature name to install"
  end

  newparam(:accept_license) do
    desc "Setting to accept license agreement, must be true"
    defaultto :true
    newvalues(:true)
  end

  newparam(:install_type) do
    desc "Type of install to use.  Valid values are usr or extention"
    defaultto "usr"
    newvalues("usr", "extension")
  end

  newparam(:install_from) do
    desc "Where to install from.  If left blank default online repo is used"
  end

  newparam(:download_deps) do
    desc "Whether or not to download dependencies.  Valid are true/false"
    defaultto :true
    newvalues(:true, :false)
  end

  newparam(:verbose) do
    desc "Enable verbose output"
    newvalues(:true, :false)
  end

  newparam(:base_path) do
    desc "Installation path for WLP"
    validate do |value|
      if value.empty?
        raise ArgumentError, "Base path must be an absolute path: #{value}"
      end
    end
  end

  newparam(:wlp_user) do
    desc "user that WLP is installed/running as"
    validate do |value|
      if value.empty?
      end
    end
  end

  validate do
    [:base_path,:wlp_user].each do |p|
      if parameters[p].nil?
        raise ArgumentError, "Parameter #{p} must be provided!"
      end
    end
  end

end
