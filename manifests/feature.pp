define wlp::feature (
  $ensure    = 'present',
  $user      = $::wlp::wlp_user,
  $base_path = $::wlp::base_path,
){
  Class[::wlp] -> Wlp::Feature[$title]

  wlp_feature {$title:
      ensure    => $ensure,
      base_path => $base_path,
      wlp_user  => $user,
  }
}
