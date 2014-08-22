actions :create, :delete

default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :date, :kind_of => String, :required => true
attribute :by, :kind_of => String, :required => true
attribute :banned_until, :kind_of => String, :required => true
attribute :reason, :kind_of => String, :required => true

attr_accessor :banned


