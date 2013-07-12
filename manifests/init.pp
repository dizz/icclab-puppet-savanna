# == Class: savanna
#
# Installs the savanna backend.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { savanna:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Andy Edmonds <andy@edmonds.be>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class savanna (
  $local_settings_template = 'savanna/savanna.conf.erb',
) {

  if !defined(Package['python-pip']) {
      package { 'python-pip':
      ensure => latest,
    }
  }

  exec { "savanna":
    command => "pip install http://tarballs.openstack.org/savanna/savanna-master.tar.gz#egg=savanna",
    path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    #refreshonly => true,
  }

  # Waiting for new version
  #package { "savanna":
  #	ensure => installed,
  #	provider => pip,
  #} ~>

  group { 'savanna':
    ensure  => present,
    system  => true,
    #require => Exec['savanna'],
  } ~>

  user { 'savanna':
    ensure  => present,
    gid     => 'savanna',
    system  => true,
    home    => '/var/lib/savanna',
    shell   => '/bin/false'
    #require => Exec['savanna'],
  } ~>

  file { "/var/lib/savanna":
    ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ~>

  file { "/etc/savanna":
  	ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ~>

  file { "/etc/savanna/savanna.conf":
    path    => '/etc/savanna/savanna.conf',
    ensure => file,
    content => template($local_settings_template),
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ~>

  file { "/etc/init.d/savanna-api":
    path    => '/etc/init.d/savanna-api',
    ensure => file,
    content => template('savanna/savanna-api.erb'),
    mode   => 755,
    owner  => 'root',
    group  => 'root',
  } ~>

  file { "/etc/savanna/savanna-api.conf":
    path    => '/etc/init/savanna-api.conf',
    ensure => file,
    content => template('savanna/savanna-api.conf.erb'),
    mode   => 755,
    owner  => 'root',
    group  => 'root',
  } ~>

  #exec { "cp /usr/local/share/savanna/savanna.conf.sample /etc/savanna/savanna.conf":
  #	command => "cp /usr/local/share/savanna/savanna.conf.sample /etc/savanna/savanna.conf",
  #	path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  #	refreshonly => true,
  #}

  exec { "/usr/local/bin/savanna-db-manage --config-file /etc/savanna/savanna.conf current":
  	command => "/usr/local/bin/savanna-db-manage --config-file /etc/savanna/savanna.conf current",
  	#path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  	#refreshonly => true,
  } ~>

  #exec { "savanna-api --config-file /etc/savanna/savanna.conf":
  #  command => "/usr/local/bin/savanna-api --config-file /etc/savanna/savanna.conf &",
  #  #path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  #  #refreshonly => true,
  #}
  
  # need to install disk builder and create image
  # or generate and install
  # https://savanna.readthedocs.org/en/latest/userdoc/diskimagebuilder.html

  # no init scripts
  # --config-file /etc/savanna/savanna.conf
  service { "savanna-api":
    enable => true,
  	ensure => running,
  	hasrestart => true,
  	hasstatus => true,
  	#require => Class["config"],
  }
}
