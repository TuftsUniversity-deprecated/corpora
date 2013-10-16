class Annotation < ActiveRecord::Base
  attr_accessible :json, :text, :pid
  serialize :json, JSON
end
