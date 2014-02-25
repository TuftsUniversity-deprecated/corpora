
class Annotation < ActiveRecord::Base
###  attr_accessible :json, :text, :pid, :term, :term_type, :utterance
  serialize :json, JSON
  after_save :index_object
  after_destroy :index_object

  def index_object
    reindex_object self.pid
  end

  def reindex_object pid
    @document_fedora = TuftsBase.find(pid, :cast=>true)
    @document_fedora.update_index
  end
  handle_asynchronously :reindex_object
end
