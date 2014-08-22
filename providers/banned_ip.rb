def whyrun_supported?
  true
end

use_inline_resources

action :create do
  bash "insert_name" do
    user node['minecraft']['user']
    code "echo '" + 
      new_resource.name + "|" + new_resource.date + "|" + 
      new_resource.by + "|" + new_resource.banned_until + "|" + new_resource.reason +
      "' >> " + node['minecraft']['install_dir'] + "/banned-ips.txt"
    not_if "grep -q '^" + new_resource.name + "\|' " + node['minecraft']['install_dir'] + "/banned-ips.txt"
  end
end

action :delete do
  bash "remove_name" do
    user node['minecraft']['user']
    code "sed -i '/^ " + new_resource.name + "\|/d' " + node['minecraft']['install_dir'] + "/banned-ips.txt"
  end
end
