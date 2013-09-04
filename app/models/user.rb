class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
# Connects this user object to Hydra behaviors.
 include Hydra::User# Connects this user object to Role-management behaviors. 
 include Hydra::RoleManagement::UserRoles

# Connects this user object to Blacklights Bookmarks. 
 include Blacklight::User

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_ids
  # attr_accessible :title, :body

  rails_admin do
     object_label_method :email
  end


  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end
  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    email
  end
end
