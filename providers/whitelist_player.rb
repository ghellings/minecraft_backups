def whyrun_supported?
  true
end

use_inline_resources

action :create do
  bash "insert_name" do
    user node['minecraft']['user']
    code "echo '" + new_resource.name + "' >> " + node['minecraft']['install_dir'] + "/white-list.txt"
    not_if "grep -q '^" + new_resource.name + "$' " + node['minecraft']['install_dir'] + "/white-list.txt"
  end
end

action :delete do
  bash "remove_name" do
    user node['minecraft']['user']
    code "sed -i '/^ " + new_resource.name + "$/d' " + node['minecraft']['install_dir'] + "/white-list.txt"
  end
end
