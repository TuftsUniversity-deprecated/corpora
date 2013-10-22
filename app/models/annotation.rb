class Annotation < ActiveRecord::Base
  attr_accessible :json, :text, :pid, :term, :term_type
  serialize :json, JSON
end
