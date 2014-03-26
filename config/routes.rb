ALLOW_DOTS ||= /[a-zA-Z0-9_.:\-]+/

SouthAsianDigitalLibrary::Application.routes.draw do


  get "site/docs"
  get "site/about"
  match '/contact',     to: 'contacts#new',             via: 'get'
  resources "contact", only: [:new, :create], :as => 'contacts'

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  root :to => "catalog#index"


  Blacklight.add_routes(self)
  resources :catalog, :only => [:show, :update], :constraints => {:id => ALLOW_DOTS, :format => false}


  resources :unpublished, :only => :index
  # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
  resources :solr_document, :path => 'catalog', :controller => 'catalog', :only => [:show, :update]
  resources :downloads, :only => [:show], :constraints => {:id => ALLOW_DOTS
  }
  resources :downloads, :only => [:show], :constraints => {:id => ALLOW_DOTS}

  resources :bookmarks, :path => 'catalog'
  resources :search_history, :path => 'search_history', :only => [:index, :show]

  HydraHead.add_routes(self)

  #mount HydraEditor::Engine => '/'
  post 'records/:id/publish', to: 'records#publish', as: 'publish_record', constraints: {id: ALLOW_DOTS}

  resources :records, only: [:destroy], constraints: {id: ALLOW_DOTS} do
    member do
      delete 'cancel'
    end
    resources :attachments, constraints: {id: ALLOW_DOTS}
  end

  resources :generics, only: [:edit, :update], constraints: {id: ALLOW_DOTS}

  get '/api/search', :to => 'annotations#search'
  get '/api', :to => 'annotations#index'
  get '/api/annotations', :to => 'annotations#list'
  get 'names', :to => 'catalog#get_names'
  post '/api/annotations', :to => 'annotations#create'
  delete '/api/annotations/:id', :to => 'annotations#destroy'
  put '/api/annotations/:id', :to => 'annotations#update'

  get '/file_assets/medium/:id', :to => 'local_file_assets#showMedium', :constraints => {:id => /.*/}
  get '/file_assets/webm/:id', :to => 'local_file_assets#showWebm', :constraints => {:id => /.*/}
  get '/file_assets/:id', :to => 'local_file_assets#show', :constraints => {:id => /.*/}

  # for ajax calls, pid contains period characters which, by default, are a routing separator
  get '/catalog/get_external_references/:pid/:name' => 'catalog#get_external_references', :constraints => {:pid => /[^\/]+/, :name => /.*/}
  get '/catalog/get_internal_references/:pid/:name' => 'catalog#get_internal_references', :constraints => {:pid => /[^\/]+/, :name => /.*/}
  get '/catalog/get_references/:pid/:name' => 'catalog#get_references', :constraints => {:pid => /[^\/]+/, :name => /.*/}
  get '/catalog/transcriptonly/:id' => 'catalog#transcriptonly', :constraints => {:id => /.*/}, :as => 'transcriptonly'

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

end
