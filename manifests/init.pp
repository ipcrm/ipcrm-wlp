class wlp (
  $install_src,
  $manage_user     = $::wlp::params::manage_user,
  $manage_java     = $::wlp::params::manage_java,
  $base_path        = $::wlp::params::base_path,
  $wlp_user        = $::wlp::params::wlp_user,
) inherits ::wlp::params {

  if $manage_java == true {
    class{'::java': }
  }

  if $manage_user == true {
    user{$wlp_user:
      comment    => 'Websphere Liberty Profile User',
      home       => $base_path,
      managehome => false,
    }
  }

  # Create Install Dir
  file{$base_path:
    ensure => directory,
    owner  => $wlp_user,
    group  => $wlp_user,
    mode   => '0755',
  }

  # Download/Deploy Archive
  $_archive = basename($install_src)
  archive { $_archive:
    path         => "${base_path}/${_archive}",
    source       => $install_src,
    extract      => true,
    extract_path => $base_path,
    creates      => "${base_path}/wlp",
    user         => $wlp_user,
    group        => $wlp_user,
    require      => File[$base_path],
    notify       => Exec["fix perms on ${base_path}/wlp/bin"],
  }

  # Ensure Bin directory contents is executable (depending on src, not always the case)
  exec { "fix perms on ${base_path}/wlp/bin":
    refreshonly => true,
    command     => "find ${base_path}/wlp/bin -type f ! -name *.jar -exec chmod 0750 {} \\;",
    path        => $::path,
  }

}
