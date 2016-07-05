define wlp::server (
  String  $user,
  String  $base_path,
  String  $server_config = '',
  String  $ensure = 'present',
  Boolean $enable = true,
){

  Class[::wlp] -> Wlp::Server[$title]

  wlp_server{$title:
    ensure    => $ensure,
    base_path => $base_path,
    wlp_user  => $user,
  }

  $server_config_file = "${base_path}/usr/servers/${title}/server.xml"
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
      base_path => $base_path,
      wlp_user  => $user,
    }
  }

}
