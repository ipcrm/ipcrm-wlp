class wlp (
  $manage_firewall = $::wlp::params::manage_firewall,
  $manage_user     = $::wlp::params::manage_user,
  $manage_java     = $::wlp::params::manage_java,
  $base_dir        = $::wlp::params::base_dir,
  $install_src     = $::wlp::params::install_src,
  $wlp_user        = $::wlp::params::wlp_user,
) inherits ::wlp::params {

  if $manage_java == true {
    class{'::java': }
  }

  if $manage_user == true {
    user{$wlp_user:
      comment    => 'Websphere Liberty Profile User',
      home       => $base_dir,
      managehome => false,
    }
  }

  # Create Install Dir
  file{$base_dir:
    ensure => directory,
    owner  => $wlp_user,
    group  => $wlp_user,
    mode   => '0755',
  }

  # Download/Deploy Zip
  archive { $install_src:
    path         => $install_src,
    extract      => true,
    extract_path => $base_dir,
    creates      => "${base_dir}/wlp",
    user         => $wlp_user,
    group        => $wlp_user,
    require      => File[$base_dir],
  }

  ## Deploy features, via a define wlp::feature_setup
  # Create Server(s), via a define wlp::server/Manage firewall for each server

  # Deploy 'drop-in' apps

  # Deploy 'static' apps


}
