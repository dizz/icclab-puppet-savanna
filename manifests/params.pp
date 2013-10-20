class savanna::params {
  
  $sys_rundir                  = '/var/run'
  $savanna_service             = 'savanna-api'
  $savanna_logdir              = '/var/log/savanna'
  $savanna_rundir              = '/var/run/savanna'
  $savanna_lockdir             = '/var/lock/savanna'
  $savanna_conf_file           = '/etc/savanna/savanna.conf'
  $savanna_syslog              = false
  $savanna_usefips             = false
  $savanna_node_domain         = 'novalocal'
  #installs source version from github builds
  $development                 = true
  $development_build_url       = 'http://tarballs.openstack.org/savanna/savanna-0.3.tar.gz#egg=savanna'
  $development_dashboard_build_url = 'http://tarballs.openstack.org/savanna-dashboard/savanna-dashboard-0.3.tar.gz'

  #these two paths are OS specific - on redhat they're diff
  $horizon_settings            = '/usr/share/openstack-dashboard/openstack_dashboard/settings.py'
  $horizon_local_settings      = '/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.py'
}
