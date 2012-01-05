class User
  
  include Mongoid::Document

  field :name,    :type  => String
  field :email,   :email => String
  
  embeds_many :profiles

end
