class wlp (
  $install_src,
  $manage_user     = $::wlp::params::manage_user,
  $manage_java     = $::wlp::params::manage_java,
  $base_dir        = $::wlp::params::base_dir,
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

  # Download/Deploy Archive
  $_archive = basename($install_src)
  archive { $_archive:
    path         => "${base_dir}/${_archive}",
    source       => $install_src,
    extract      => true,
    extract_path => $base_dir,
    creates      => "${base_dir}/wlp",
    user         => $wlp_user,
    group        => $wlp_user,
    require      => File[$base_dir],
  }

  # Create symlink for install
  file {'/usr/local/wlp':
    ensure  => link,
    target  => "${base_dir}/wlp",
    require => Archive[$_archive],
  }

  # Ensure Bin directory contents is executable (depending on src, not always the case)
  file { "${base_dir}/wlp/bin":
    ensure  => directory,
    owner   => $wlp_user,
    group   => $wlp_user,
    recurse => true,
    mode    => '0750',
    require => Archive[$_archive],
  }
}
