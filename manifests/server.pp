define wlp::server (
  String  $ensure        = 'present',
  Boolean $enable        = true,
  String  $user          = $::wlp::wlp_user,
  String  $base_path     = $::wlp::base_path,
  String  $server_config = '',
){

  Class[::wlp] -> Wlp::Server[$title]

  $install_path = "${base_path}/wlp"

  wlp_server{$title:
    ensure    => $ensure,
    base_path => $install_path,
    wlp_user  => $user,
  }

  $server_config_file = "${install_path}/usr/servers/${title}/server.xml"
  if $server_config != '' {
    file{$server_config_file:
      ensure  => $ensure,
      content => $server_config,
      owner   => $user,
      group   => $user,
      require => Wlp_server[$title],
      before  => Wlp_server_control[$title],
      notify  => Wlp_server_control[$title],
    }
  }

  $_state = $enable ? { true => 'running', false =>'stopped' }

  if $ensure == 'present' {
    wlp_server_control {$title:
      ensure    => $_state,
      base_path => $install_path,
      wlp_user  => $user,
    }
  }

}
