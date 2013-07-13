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
# TODOs
# - need to install disk builder and create image
#   or generate and install
#   https://savanna.readthedocs.org/en/latest/userdoc/diskimagebuilder.html
# - parameterise config - keystone and database
#   db and keystone setup, note the todo in keystone service URL
# - provide mysql DB support - only sqlite atm

class savanna (
  $savanna_host              = '127.0.0.1',
  $savanna_port              = '8386',
  $db_host                   = '127.0.0.1',
  $savanna_db_name           = 'savanna',
  $savanna_db_user           = 'savanna',
  $savanna_db_password       = 'savanna',
  $keystone_auth_protocol    = 'http',
  $keystone_auth_host        = '127.0.0.1',
  $keystone_auth_port        = '35357',
  $keystone_user             = 'savanna',
  $keystone_password         = 'savanna',
  $keystone_tenant           = undef,
  $hadoop_image_builder      = true,
  $savanna_verbose           = false,
  $savanna_debug             = false,
  $local_settings_template   = 'savanna/savanna.conf.erb',
) {

  include savanna::params

  if !$keystone_tenant {
    $int_keystone_tenant = $keystone_user
  }else {
    $int_keystone_tenant = $keystone_tenant
  }

  if !defined(Package['python-pip']) {
      package { 'python-pip':
      ensure => latest,
    }
  }

  if $savanna::params::development {
    info('Installing and using the savanna development version.')
    exec { "savanna":
      command => "pip install http://tarballs.openstack.org/savanna/savanna-master.tar.gz#egg=savanna",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    }
  } else {
    error('Please set horizon::params::development to true. Waiting for new release before using pip.')
  }
  
  # scope.lookupvar("horizon::params::savana_dashboard") 

  group { 'savanna':
    ensure  => present,
    system  => true,
  } ~>

  user { 'savanna':
    ensure  => present,
    gid     => 'savanna',
    system  => true,
    home    => '/var/lib/savanna',
    shell   => '/bin/false'
  } ~>

  file { "/var/lib/savanna":
    ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ~>

  file { "/var/log/savanna":
    ensure => "directory",
    owner  => "savanna",
    group  => "savanna",
    mode   => 750,
  } ~>

  file { "/var/log/savanna/savanna.log":
    ensure => "file",
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
  }

  if $::osfamily == 'Debian' {

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
    }
  } else {
    error('Savanna cannot be installed on this operating system. It does not have the supported initscripts. There is only support for Debian-based systems.')
  }

  exec { "/usr/local/bin/savanna-db-manage --config-file /etc/savanna/savanna.conf current":
  	command => "/usr/local/bin/savanna-db-manage --config-file /etc/savanna/savanna.conf current",
  } ~>

  #TODO(dizz) need to notify if service config changes
  service { "savanna-api":
    enable => true,
  	ensure => running,
  	hasrestart => true,
  	hasstatus => true,
  }

  if $hadoop_image_builder {
    warning ('Installation of the hadoop image builder tools is not implemented')
  }
}
