require_relative '../spec_helper'

describe 'my_minecraft::default' do
  before do
    stub_command("rpm -qa | grep -q '^runit'").and_return(false)
    stub_data_bag("banned_players").and_return([])
    stub_data_bag("banned_ips").and_return([])
    stub_data_bag("whitelist_players").and_return([])
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
    it { should include_recipe 'minecraft' }
    it { should include_recipe 'java' }
  
    let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
    
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
  end
end


















