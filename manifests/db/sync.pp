#
# Used to create the savanna db structure
#

class savanna::db::sync {

  include cinder::params

  exec { 'savanna-db-manage-db-sync':
  	#TODO(dizz): externalise
    command     => $::savanna::params::savanna_db_sync_cmd,
    path        => '/usr/bin',
    refreshonly => true,
    require     => [File[$::savanna::params::savanna_conf_file], Class['savanna::db::mysql']],
    logoutput   => 'on_failure',
  }
}
