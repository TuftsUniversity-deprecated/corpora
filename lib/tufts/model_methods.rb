# COPIED From https://github.com/mkorcy/tdl_hydra_head/blob/master/lib/tufts/model_methods.rb
require 'chronic'
require 'titleize'
require 'tufts/metadata_methods'
# MISCNOTES:
# There will be no facet for RCR. There will be no way to reach RCR via browse.
# 3. There will be a facet for "collection guides", namely EAD, namely the landing page view we discussed on Friday.

module Tufts
  module ModelMethods

  include TuftsFileAssetsHelper
  include Tufts::IndexingMethods
  include Tufts::MetadataMethods

  def create_facets(solr_doc)
  #   index_names_info(solr_doc)
  #   index_subject_info(solr_doc)
  #   index_collection_info(solr_doc)
  #   index_date_info(solr_doc)
      index_format_info(solr_doc)
  #   index_pub_date(solr_doc)
  #   index_unstemmed_values(solr_doc)
      index_utterance_metadata(solr_doc)
  end

  private

    def index_utterance_metadata solr_doc
      AnnotationTools.tag_things(self.pid.to_s,self,false,solr_doc)
      AnnotationTools.tag_things(self.pid.to_s,self,true)
      solr_doc
    end
  end
end

