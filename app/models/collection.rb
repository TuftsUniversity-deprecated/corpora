require 'corpora_object'

class Collection < ActiveRecord::Base

  has_and_belongs_to_many :corpora_objects
  #has_and_belongs_to_many :collection
  after_save :after_save_reindex_collection

  #def before_destroy
  #  after_save_reindex_collection
  #end

  def destroy

    objs_preloaded = []
    self.corpora_objects.each do |obj|
      objs_preloaded.push obj
    end
    super
    reindex_collection objs_preloaded

  end

  def after_save_reindex_collection
    reindex_collection_after_save
  end

  def reindex_collection_after_save


      puts "TEST: #{self.corpora_objects}"
      self.corpora_objects.each do |obj|
        @document_fedora = TuftsBase.find(obj.pid, :cast=>true)
        @document_fedora.update_index
      end
    end
  def reindex_collection objs


    #puts "TEST: #{self.corpora_objects}"
    objs.each do |obj|
      @document_fedora = TuftsBase.find(obj.pid, :cast=>true)
      @document_fedora.update_index
    end
  end

  handle_asynchronously :reindex_collection
  handle_asynchronously :reindex_collection_after_save

end
