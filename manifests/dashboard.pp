class savanna::dashboard (
	$savanna_host          = '127.0.0.1',
    $savanna_port          = '8386',
    $use_neutron           = true,
	$savanna_dev_dashboard = true,
){

	if !defined(Package['python-pip']) {
	  package { 'python-pip':
	    ensure => latest,
	  }
	}

	if $savanna_dev_dashboard{
	  info ('Installing the developement version of savanna dashboard')
	  exec { "savannadashboard":
	    command => "pip install ${::savanna::params::development_dashboard_build_url}",
	    path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
	    unless => "stat /usr/local/lib/python2.7/dist-packages/savannadashboard",
	    require => Package['python-pip'],
	  }  
	} else {
	  package { "savannadashboard":
	    ensure => installed,
	    provider => pip,
	    require => Package['python-pip'],
	  }  
	}

	exec { "savanna-dash-1":
      command => "sed -i \"s/('project', 'admin', 'settings',)/('project', 'admin', 'settings', 'savanna',)/\" ${savanna::params::horizon_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"savanna\" ${savanna::params::horizon_settings}",
      #require => Package['python-pip'],
    }

    exec { "savanna-dash-2":
      command => "sed -i \"/^INSTALLED_APPS = [^l]/{s/$/\\n    'savannadashboard',/}\" ${savanna::params::horizon_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"savannadashboard\" ${savanna::params::horizon_settings}",
      #require => Package['python-pip'],
    }
	
	exec { "savanna-dash-3":
      command => "echo 'SAVANNA_USE_NEUTRON = ${use_neutron}' >> ${savanna::params::horizon_local_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"SAVANNA_USE_NEUTRON\" ${savanna::params::horizon_local_settings}",
      #require => Package['python-pip'],
    }

    exec { "savanna-dash-4":
      command => "echo \"SAVANNA_URL = 'http://${savanna_host}:${savanna_port}/v1.1'\" >> ${savanna::params::horizon_local_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"SAVANNA_URL\" ${savanna::params::horizon_local_settings}",
      #require => Package['python-pip'],
    }

}