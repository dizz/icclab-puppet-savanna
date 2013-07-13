class savanna::params {
  
  $sys_rundir          = '/var/run'
  $savanna_service     = 'savanna-api'
  $savanna_logdir      = '/var/log/savanna'
  $savanna_rundir      = '/var/run/savanna'
  $savanna_lockdir     = '/var/lock/savanna'
  $savanna_conf_file   = '/etc/savanna/savanna.conf'
  $savanna_syslog      = false
  $savanna_usefips     = false
  $savanna_node_domain = 'novalocal'
  #installs developement version from github builds
  $development = true
}
