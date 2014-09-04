require 'spec_helper'

describe service('minecraft') do
  it { should be_running }
end

describe port(25565) do
  it { should be_listening }
end

describe cron do 
  it { should have_entry('0 * * * * nice -n 19 ionice -c2 -n7 /srv/minecraft/backups/backup.sh hourly').with_user('mcserver') }
  it { should have_entry('* 0 * * * nice -n 19 ionice -c2 -n7 /srv/minecraft/backups/backup.sh daily').with_user('mcserver') }
end

describe user('mcserver') do
  it { should exist }
  it { should belong_to_group 'mcserver' }
end

describe file('/srv/minecraft') do
  it { should be_directory }
  it { should be_owned_by "mcserver" }
  it { should be_grouped_into "mcserver" }
end

describe file('/srv/minecraft/backups') do
  it { should be_directory }
  it { should be_owned_by "mcserver" }
  it { should be_grouped_into "mcserver" }
end

describe file('/srv/minecraft/backups/daily') do
  it { should be_directory }
  it { should be_owned_by "mcserver" }
  it { should be_grouped_into "mcserver" }
end


describe file('/srv/minecraft/backups/hourly') do
  it { should be_directory }
  it { should be_owned_by "mcserver" }
  it { should be_grouped_into "mcserver" }
end

describe file('/srv/minecraft/backups/backup.sh') do
  it { should be_file }
  it { should be_owned_by "mcserver" }
  it { should be_grouped_into "mcserver" }
  it { should be_executable }
end

describe command('/srv/minecraft/backups/backup.sh') do
  it { should return_stdout 'Takes one argument.' }
end

describe file('/etc/chef/ohai_plugins/ohai_banned_users.rb') do
  it { should be_file}
end

describe file('/etc/chef/ohai_plugins/ohai_backup_history.rb') do
  it { should be_file}
end

describe file('/etc/monit.conf') do
  it { should_not be_file}
end


describe command('ohai -d /etc/chef/ohai_plugins/') do
  it { should return_stdout /"minecraft_banned": *{\n *"players": *\[\n[^\]]*"notch"[^\]]*"zach"[^\]]*\],\n *"ips": *\[\n[^\]]*"8\.8\.8\.8"[^\]]*\]/ }
  it { should return_stdout /"minecraft_backup_history": *{\n *"all": \[\n[^\]]*\]\n *}/ }
  it { should return_stdout /"minecraft_uptime": *{\n *"uptime": ".+"\n *}/ }
end
