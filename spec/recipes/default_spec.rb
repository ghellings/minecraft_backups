require_relative '../spec_helper'

describe 'my_minecraft::default' do
  before do
    stub_command("rpm -qa | grep -q '^runit'").and_return(false)

    stub_data_bag("banned_players").and_return(["zach"])
    stub_data_bag_item("banned_players", "zach").and_return({
      "date" => "10/10/10",
      "by" => "chefspec",
      "banned_until" => "10/11/10",
      "reason" => "for testing"
    })

    stub_data_bag("banned_ips").and_return(["8.8.8.8"])
    stub_data_bag_item("banned_ips", "8.8.8.8").and_return({
      "date" => "10/10/10",
      "by" => "chefspec",
      "banned_until" => "10/11/10",
      "reason" => "for testing"
    })

    stub_data_bag("whitelist_players").and_return(["notch"])

    stub_command("grep -q '^zach|' /srv/minecraft/banned-players.txt").and_return(false)
    stub_command("grep -q '^8.8.8.8|' /srv/minecraft/banned-ips.txt").and_return(false)
    stub_command("grep -q '^notch$' /srv/minecraft/white-list.txt").and_return(false)
  end

  subject do 
    runner = ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '6.4'
    )
    runner.node.set['memory']['total'] = '1696516kb'
    runner.converge(described_recipe) 
  end

  context 'minecraft backups' do
    it { should include_recipe "ohai"}
    it { should include_recipe 'minecraft' }
    it { should include_recipe 'java' }
    it { should delete_file '/etc/monit.conf'}
  
    let(:chef_run) { ChefSpec::Runner.new(step_into: ['my_minecraft_banned_ip', 'my_minecraft_banned_player', 'my_minecraft_whitelist_player']).converge(described_recipe) }
 
    it 'creates ohai plugins from template' do
      expect(chef_run).to render_file "/etc/chef/ohai_plugins/ohai_banned_users.rb"
      expect(chef_run).to render_file "/etc/chef/ohai_plugins/ohai_backup_history.rb"
      expect(chef_run).to render_file "/etc/chef/ohai_plugins/ohai_uptime.rb"
    end

    it 'creates directory tree for minecraft backups' do
      expect(chef_run).to create_directory(chef_run.node['minecraft']['backups']['dir']).with(
        user: chef_run.node['minecraft']['user'],
        group: chef_run.node['minecraft']['group'],
        mode: 0755,
        recursive: true
      )
  
      chef_run.node['minecraft']['backups']['scheme'].each do |dir|  
        expect(chef_run).to create_directory(chef_run.node['minecraft']['backups']['dir'] + '/' + dir['name']).with(
          user: chef_run.node['minecraft']['user'],
          group: chef_run.node['minecraft']['group'],
          mode: 0755,
          recursive: true
        )
      end
    end
    
    it 'creates minecraft.conf for monit' do
      expect(chef_run).to create_template("/etc/monit/conf.d/minecraft.conf")
    end

    it 'creates backup.sh script for minecraft' do
      expect(chef_run).to create_template(chef_run.node['minecraft']['backups']['script_loc']).with(
          user: chef_run.node['minecraft']['user'],
          group: chef_run.node['minecraft']['group'],
          mode: 0755
      )
    end
  
    it 'creates cron jobs for minecraft server backup' do
      chef_run.node['minecraft']['backups']['scheme'].each do |routine|
        expect(chef_run).to create_cron(routine['name'] + "_minecraft_backup")
      end
    end

    it 'checks backup scheme' do
      chef_run.node['minecraft']['backups']['scheme'].each do |routine|
          expect(routine['name'] == nil).to eq(false)
          expect(routine['minute'] != nil || routine['hour'] != nil).to eq(true)
          expect(routine['minute'] == nil || routine['hour'] == nil).to eq(true)
          expect(routine['lifespan'] == nil || routine['lifespan']['hours'] == nil || routine['lifespan']['days'] == nil).to eq(true)
      end
    end

    it 'creates player banned/whitelist data' do
      expect(chef_run).to ban_player("zach")
      expect(chef_run).to ban_ip("8.8.8.8")
      expect(chef_run).to whitelist_player("notch")
    end
  end
end


















