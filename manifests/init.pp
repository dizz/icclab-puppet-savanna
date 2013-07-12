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
class savanna {

  package { "python-pip":
  	ensure => installed,
  } ~>

  package { "savanna":
  	ensure => installed,
  	provider => pip
  } ~>

  file { "/etc/savanna":
  	ensure => file,
  } ~>

  exec { "cp /usr/local/share/savanna/savanna.conf.sample /etc/savanna/savanna.conf":
  	command => "cp /usr/local/share/savanna/savanna.conf.sample /etc/savanna/savanna.conf",
  	#path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  	#refreshonly => true,
  } ~>

  exec { "savanna-manage --config-file /etc/savanna/savanna.conf reset-db --with-gen-templates":
  	command => "savanna-manage --config-file /etc/savanna/savanna.conf reset-db --with-gen-templates",
  	#path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  	#refreshonly => true,
  } ~>

  # --config-file /etc/savanna/savanna.conf
  service { "savanna-api":
    enable => true,
  	ensure => running,
  	#hasrestart => true,
  	#hasstatus => true,
  	#require => Class["config"],
  }
}
