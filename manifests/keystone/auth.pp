class savanna::keystone::auth (
  $password,
  $auth_name          = 'savanna',
  $email              = 'savanna@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_type       = 'mapreduce',
  $public_address     = '127.0.0.1',
  $admin_address      = '127.0.0.1',
  $internal_address   = '127.0.0.1',
  $port               = '8386',
  $public_port        = undef,
  $region             = 'RegionOne',
  $public_protocol    = 'http'
) {

  # removed $volume_version     = 'v1',

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'savanna-api' |>

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }

  keystone_user { $auth_name:
    ensure   => present,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }
  keystone_user_role { "${auth_name}@${tenant}":
    ensure  => present,
    roles   => 'admin',
  }
  keystone_service { $auth_name:
    ensure      => present,
    type        => $service_type,
    description => 'Savanna MapReduce Service',
  }

  # public_url   => "${public_protocol}://${public_address}:${port}/${volume_version}/%(tenant_id)s",
  # admin_url    => "http://${admin_address}:${port}/${volume_version}/%(tenant_id)s",
  # internal_url => "http://${internal_address}:${port}/${volume_version}/%(tenant_id)s",
  # TODO - fix me
  if $configure_endpoint {
    keystone_endpoint { "${region}/${auth_name}":
      ensure       => present,
      public_url   => "${public_protocol}://${public_address}:${real_public_port}/",
      internal_url => "http://${internal_address}:${port}/",
      admin_url    => "http://${admin_address}:${port}/",
    }
  }
}
