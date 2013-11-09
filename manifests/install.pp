# Class: savanna::install
#
#
class savanna::install {
  
  include savanna::params

  # this is here until this fix is released
  # https://bugs.launchpad.net/ubuntu/+source/python-pbr/+bug/1245676
  if !defined(Package['git']) {
    package { 'python-pip':
      ensure => latest,
    }
  }

  if !defined(Package['python-pip']) {
    package { 'python-pip':
      ensure  => latest,
      require => Package['git']
    }
  }

  if $savanna::params::development {
    info("Installing and using the savanna development version. URL: ${savanna::params::development_build_url}")
    exec { "savanna":
      command => "pip install ${savanna::params::development_build_url}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "stat /usr/local/lib/python2.7/dist-packages/savanna",
      require => Package['python-pip'],
    }
  } else {
    package { "savanna":
      ensure => installed,
      provider => pip,
      require => Package['python-pip'],
    }
  }
  
  group { 'savanna':
    ensure  => present,
    system  => true,
  } ->

  user { 'savanna':
    ensure  => present,
    gid     => 'savanna',
    system  => true,
    home    => '/var/lib/savanna',
    shell   => '/bin/false'
  } ->

  file { "/var/lib/savanna":
    ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ->

  file { "/var/log/savanna":
    ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ->

  file { "/var/log/savanna/savanna.log":
    ensure => "file",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ->

  file { "/etc/savanna":
  	ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ->

  file { "/etc/savanna/savanna.conf":
    path    => '/etc/savanna/savanna.conf',
    ensure  => file,
    content => template('savanna/savanna.conf.erb'),
    owner   => "savanna",
    group   => "savanna",
    mode    => 750,
    before  => Class['::savanna::db::sync']
  }

  if $::osfamily == 'Debian' {

    file { "/etc/init.d/savanna-api":
      path    => '/etc/init.d/savanna-api',
      ensure  => file,
      content => template('savanna/savanna-api.erb'),
      mode    => 755,
      owner   => 'root',
      group   => 'root',
    } ->

    file { "/etc/savanna/savanna-api.conf":
      path    => '/etc/init/savanna-api.conf',
      ensure  => file,
      content => template('savanna/savanna-api.conf.erb'),
      mode    => 755,
      owner   => 'root',
      group   => 'root',
      notify  => Service["savanna-api"],
    }
  } else {
    error('Savanna cannot be installed on this operating system. It does not have the supported initscripts. There is only support for Debian-based systems.')
  }
}