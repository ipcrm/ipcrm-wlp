define wlp::deploy_app (
  String $user,
  String $base_path,
  String $server,
  String $install_src,
  String $type = Enum['dropin', 'static'],
  String $ensure = 'present',
){

  Class[::wlp] -> Wlp::Deploy_app[$title]

  case $ensure {
      'present': {
        # Download/Deploy Archive
        $_archive = basename($install_src)

        # Validate $title/$name matches $_archive
        if $_archive != $name {
          fail("Archive name MUST match the app name(they don't, failing)! Archive: ${_archive} App: ${title}")
        }

        # Set path for app location based on type
        $_app_path = $type ? {'dropin' => 'dropins', 'static' => 'apps' }

        # Deploy archive of app
        case $type {
          'static': {
            archive { $_archive:
              path   => "${base_path}/usr/servers/${server}/${_app_path}/${_archive}",
              source => $install_src,
              user   => $user,
              group  => $user,
              notify => Wlp_server_control[$server],
            }
          }
          'dropin' : {
            archive { $_archive:
              path   => "${base_path}/usr/servers/${server}/${_app_path}/${_archive}",
              source => $install_src,
              user   => $user,
              group  => $user,
            }
          }
          default : {}
        }
      }

      'absent': {
        # Set path for app location based on type
        $_app_path = $type ? {'dropin' => 'dropins', 'static' => 'apps' }
        case $type {
          'static': {
            file{"${base_path}/usr/servers/${server}/${_app_path}/${title}":
              ensure => absent,
              notify => Wlp_server_control[$server],
            }
          }
          'dropin' : {
            file{"${base_path}/usr/servers/${server}/${_app_path}/${title}":
              ensure  => absent,
            }
          }
          default : {}
        }
      }

      default: {
        fail("Unknown state requested for application ${title}: ${ensure}.")
      }
    }
}
