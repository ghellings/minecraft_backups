include_attribute 'minecraft'

default['java']['jdk_version'] = '7'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['minecraft']['backups']['dir'] = node['minecraft']['install_dir'] + '/backups'
default['minecraft']['backups']['script_loc'] = node['minecraft']['backups']['dir'] + "/backup.sh"
default['minecraft']['backups']['name_format'] = "%Y%m%d_%H%M"
default['minecraft']['backups']['fifo_path'] = node['minecraft']['install_dir'] + '/fifo';
default['minecraft']['backups']['scheme'] = [
  {
    "name" => "hourly",
    "minute" => 0,
    "lifespan" => {
      "hours" => 24
    }
  },
  {
    "name" => "daily",
    "hour" => 0,
    "lifespan" => {
      "days" => 7
    }
  }
]
