class Ability
  include Hydra::Ability

  def custom_permissions

    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Role
      #Rails Admin Verbs
      #https://github.com/sferik/rails_admin/wiki/CanCan
      #:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit
       #:show,:edit :destroy :history,:show_in_app,
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Concept
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Annotation
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Person
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], VideoUrl
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Location
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], User
      can [:index, :new, :destroy, :show, :show_in_app, :edit], CorporaObject
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Collection
      #can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], Pid
      can [:index, :new, :export, :history, :destroy, :show, :show_in_app, :edit], MediaType

      #not actually doing anything with the following in this app
#      can [:create, :edit, :update, :publish, :destroy], ActiveFedora::Base
    end
  end

  def initialize(user)
      super
      if user.has_role? :admin
        can :access, :rails_admin   # grant access to rails_admin
        can :dashboard              # grant access to the dashboard
      end

      if current_user.has_role? :annotator
        can [:annotate], CatalogController
      end

      if user.has_role? :student
        #grant access to the front end
         can [:show,:index], CatalogController
      end
    end

  def create_permissions
    # nop - override default behavior which allows any registered user to create
  end
end
