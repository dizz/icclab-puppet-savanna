# Copyright 2013 Zürcher Hochschule für Angewandte Wissenschaften
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

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
# - use a puppet type for configuration file
# - structure into sub-manifests
# - clean up documentation

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
    info("Installing and using the savanna development version. URL: ${savanna::params::development_build_url}")
    exec { "savanna":
      command => "pip install ${savanna::params::development_build_url}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "stat /usr/local/lib/python2.7/dist-packages/savanna",
      require => Package['python-pip'],
    }
  } else {
    error('Please set horizon::params::development to true. Waiting for new release before using pip.')
  }
  
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
    before => Exec['savanna-db-manage']
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

  # TODO: this runs everytime and so will destroy the DB everytime!
  exec { "savanna-db-manage":
  	command   => "/usr/local/bin/savanna-db-manage --config-file /etc/savanna/savanna.conf db-sync",
    logoutput => on_failure,
    require   => Class['savanna::db::mysql'],
    refreshonly => true
  } ~>

  #TODO(dizz) need to notify if service config changes
  service { "savanna-api":
    enable => true,
  	ensure => running,
  	hasrestart => true,
  	hasstatus => true,
  }
}
