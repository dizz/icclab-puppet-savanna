class savanna::params {
  
  $sys_rundir            = '/var/run'
  $savanna_service       = 'savanna-api'
  $savanna_logdir        = '/var/log/savanna'
  $savanna_rundir        = '/var/run/savanna'
  $savanna_lockdir       = '/var/lock/savanna'
  $savanna_conf_file     = '/etc/savanna/savanna.conf'
  $savanna_syslog        = false
  $savanna_usefips       = false
  $savanna_node_domain   = 'novalocal'
  #installs developement version from github builds
  $development           = true
  $development_build_url = 'http://tarballs.openstack.org/savanna/savanna-master.tar.gz#egg=savanna'
  #$development_build_url = 'http://tarballs.openstack.org/savanna/savanna-0.2.tar.gz#egg=savanna'
}
