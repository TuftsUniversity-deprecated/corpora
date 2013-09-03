module Tufts
  module IndexingMethods
    def create_facets(solr_doc)
    puts("A")
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