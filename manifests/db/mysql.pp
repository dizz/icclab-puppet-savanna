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
# Used to create the savanna db
#

class savanna::db::mysql (
  $password,
  $dbname        = 'savanna',
  $user          = 'savanna',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,     #['127.0.0.1'],
  $charset       = 'latin1',
) {

  Class['mysql::server'] -> Class['savanna::db::mysql']

  require mysql::python

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => $charset,
    require      => Class['mysql::config'],
  }

  # Check allowed_hosts to avoid duplicate resource declarations
  if is_array($allowed_hosts) and delete($allowed_hosts,$host) != [] {
    $real_allowed_hosts = delete($allowed_hosts,$host)
  } elsif is_string($allowed_hosts) and ($allowed_hosts != $host) {
    $real_allowed_hosts = $allowed_hosts
  }

  if $real_allowed_hosts {
    savanna::db::mysql::host_access { $real_allowed_hosts:
      user      => $user,
      password  => $password,
      database  => $dbname,
    }
  }
}
