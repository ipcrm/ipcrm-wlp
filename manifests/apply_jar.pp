define wlp::apply_jar (
  String $user,
  String $base_path,
  String $creates,
  String $install_src = $name,
  String $java_cmd = 'java',
){
  # Download/Deploy Archive
  $_archive = basename($install_src)
  archive { $_archive:
    path   => "${base_path}/${_archive}",
    source => $install_src,
    user   => $user,
    group  => $user,
  }

  exec {"extract-${_archive}":
    command   => "${java_cmd} -jar ${base_path}/${_archive} --acceptLicense ${base_path}",
    unless    => "test -e ${base_path}/${creates}",
    path      => $::path,
    logoutput => true,
    notify    => File["${base_path}/bin"],
  }

}
