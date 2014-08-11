# my_minecraft-cookbook

Extension of chef-minecraft (https://github.com/gregf/chef-minecraft) with automatic backups.

## Supported Platforms

- Ubuntu 12.04
- CentOS 6.5

## Attributes

- ['minecraft']['backups']['dir'] : Minecraft backup directory
- ['minecraft']['backups']['script_loc'] : Location of backup script
- ['minecraft']['backups']['name_format'] : Name format of tar backup archives
- ['minecraft']['backups']['scheme'] : Backup scheme. See below.

## Example backup scheme (default)

```
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
```
This will create two backup routines:

- Saved to /srv/minecraft/backups/hourly, backed up at the top of every hour, each backup kept for 24 hours
- Saved to /srv/minecraft/backups/daily, backed up every day at midnight, each backup kept for 7 days

### my_minecraft::default

Include `my_minecraft` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[my_minecraft::default]"
  ]
}
