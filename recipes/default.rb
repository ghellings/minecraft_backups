#
# Cookbook Name:: my_minecraft
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "java"
include_recipe "minecraft"

minecraft_runit_sv = resources("runit_service[minecraft]")
minecraft_runit_sv.cookbook("my_minecraft")
minecraft_runit_sv.options( {
     :install_dir => node['minecraft']['install_dir'],
     :xms         => node['minecraft']['xms'],
     :xmx         => node['minecraft']['xmx'],
     :prefer_ipv4 => node['minecraft']['prefer_ipv4'],
     :user        => node['minecraft']['user'],
     :group       => node['minecraft']['group'],
     :java_opts   => node['minecraft']['java-options'],
     :server_opts => node['minecraft']['server_opts'],
     :jar_name    => node['minecraft']['jar_name']
 }.merge(params))

directory node['minecraft']['backups']['dir'] do
  recursive true
  owner node['minecraft']['user']
  group node['minecraft']['group']
  mode 0755
  action :create
end

node['minecraft']['backups']['scheme'].each do |routine|
  directory node['minecraft']['backups']['dir'] + '/' + routine['name'] do
    recursive true
    owner node['minecraft']['user']
    group node['minecraft']['group']
    mode 0755
    action :create
  end

  cron routine['name'] + "_minecraft_backup" do
    action :create
    minute routine['minute'] == nil ? "*" : routine['minute']
    hour routine['hour'] == nil ? "*" : routine['hour']
    command "nice -n 19 ionice -c2 -n7 " + node['minecraft']['backups']['script_loc'] + ' ' + routine['name']
    user node['minecraft']['user'] 
  end
end

template node['minecraft']['backups']['dir'] + '/backup.sh' do
  source "backup.erb"
  owner node['minecraft']['user']
  group node['minecraft']['group']
  mode 0755
  action :create
  variables({
    :backup_scheme => node['minecraft']['backups']['scheme'],
    :backup_dir => node['minecraft']['backups']['dir'],
    :backup_format => node['minecraft']['backups']['name_format'],
    :minecraft_dir => node['minecraft']['install_dir']
  })
end
