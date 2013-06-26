module Tufts
  module ModelMethods

    def self.to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super
      puts "SADL"
      create_facets solr_doc
      index_sort_fields solr_doc
      solr_doc

    end
  end
end