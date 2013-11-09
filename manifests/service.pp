# Class: savanna::service
#
#
class savanna::service (
  $enable = true,
) {
  service { "savanna-api":
    enable => $enable,
  	ensure => running,
  	hasrestart => true,
  	hasstatus => true,
  }
}