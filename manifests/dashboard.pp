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

#
# Used to install savanna's horizon component
#

class savanna::dashboard (
	$savanna_host          = '127.0.0.1',
    $savanna_port          = '8386',
    $use_neutron           = true,
){
	include savanna::params

	if use_neutron {
		$neutron = 'True'
	} else {
		$neutron = 'False'
	}

	if !defined(Package['python-pip']) {
	  package { 'python-pip':
	    ensure => latest,
	  }
	}

	if $savanna::params::development {
	  info ('Installing the developement version of savanna dashboard')
	  exec { "savannadashboard":
	    command => "pip install ${::savanna::params::development_dashboard_build_url}",
	    path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
	    unless => "stat /usr/local/lib/python2.7/dist-packages/savannadashboard",
	    require => Package['python-pip'],
	  }  
	} else {
	  package { "savanna-dashboard":
	    ensure => installed,
	    provider => pip,
	    require => Package['python-pip'],
	  }  
	}

	exec { "savanna-dash-1":
      command => "sed -i \"s/('project', 'admin', 'settings',)/('project', 'admin', 'settings', 'savanna',)/\" ${savanna::params::horizon_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"savanna\" ${savanna::params::horizon_settings}",
      require => Package['savanna-dashboard'],
    }

    exec { "savanna-dash-2":
      command => "sed -i \"/^INSTALLED_APPS = [^l]/{s/$/\\n    'savannadashboard',/}\" ${savanna::params::horizon_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"savannadashboard\" ${savanna::params::horizon_settings}",
      require => Package['savanna-dashboard'],
    }
	
	exec { "savanna-dash-3":
      command => "echo 'SAVANNA_USE_NEUTRON = ${neutron}' >> ${savanna::params::horizon_local_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"SAVANNA_USE_NEUTRON\" ${savanna::params::horizon_local_settings}",
      require => Package['savanna-dashboard'],
    }

    exec { "savanna-dash-4":
      command => "echo \"SAVANNA_URL = 'http://${savanna_host}:${savanna_port}/v1.1'\" >> ${savanna::params::horizon_local_settings}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep \"SAVANNA_URL\" ${savanna::params::horizon_local_settings}",
      require => Package['savanna-dashboard'],
    }
}