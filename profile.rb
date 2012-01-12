class Profile

  include Mongoid::Document

  field :provider_id, :type => String
  field :handle  , :type => String
  field :location     , :type => String
  field :profile_name, :type => String

  embedded_in :user

end
