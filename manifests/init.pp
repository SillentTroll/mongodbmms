class mongodbmms (
  $api_key,
  $config_file  = $mongodbmms::params::config_file,
  $deb_filename = $mongodbmms::params::deb_filename,
  $download_url = $mongodbmms::params::download_url,
  $authUsername = $mongodbmms::params::authUsername,
  $authPassword = $mongodbmms::params::authPassword
) inherits mongodbmms::params {

  exec { 'download-mms':
    command => "wget ${download_url}/${deb_filename}",
    path    => ['/bin', '/usr/bin'],
    cwd    => '/tmp',
    logoutput => on_failure,
    creates => '/tmp/${deb_filename}'
  }

  exec { 'install-mms':
    command => "sudo dpkg -i ${deb_filename}",
    path    => ['/bin', '/usr/bin'],
    cwd    => '/tmp',
    logoutput => on_failure,
    require => [Exec['download-mms']]
  }

  file { '/etc/mongodb-mms/monitoring-agent.config':
    content=>template('mongodbmms/monitoring-agent.config.erb'),
    require => [Exec['install-mms']]
  }

  service { "mongodb-mms-monitoring-agent":
    ensure     => 'running',
    provider   => 'upstart',
    hasrestart => 'true',
    hasstatus  => 'true',
    require => File['/etc/mongodb-mms/monitoring-agent.config'],
    subscribe  => File['/etc/mongodb-mms/monitoring-agent.config']
  }
}