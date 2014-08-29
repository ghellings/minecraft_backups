if defined?(ChefSpec)
  def ban_player(name)
    ChefSpec::Matchers::ResourceMatcher.new(:my_minecraft_banned_player, :create, name)
  end
  def ban_ip(ip)
    ChefSpec::Matchers::ResourceMatcher.new(:my_minecraft_banned_ip, :create, ip)
  end
  def whitelist_player(name)
    ChefSpec::Matchers::ResourceMatcher.new(:my_minecraft_whitelist_player, :create, name)
  end
end
