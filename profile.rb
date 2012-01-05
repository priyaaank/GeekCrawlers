class Profile

  include Mongoid::Document

  field :provider_id, :type => String
  field :handle  , :type => String
  field :location     , :type => String

    
  embedded_in :user

end
