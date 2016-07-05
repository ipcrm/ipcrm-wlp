define wlp::feature (
  $ensure    = 'present',
  $user      = $::wlp::wlp_user,
  $base_path = $::wlp::base_path,
){
  Class[::wlp] -> Wlp::Feature[$title]

  $install_path = "${base_path}/wlp"

  wlp_feature {$title:
      ensure    => $ensure,
      base_path => $install_path,
      wlp_user  => $user,
  }
}
