require 'annotation_tools'

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
          index_corpora_collection_from_db(solr_doc)
          index_additional_terms(solr_doc)
          add_to_corpora_objects(solr_doc)
      end

      def index_corpora_collection_from_db(solr_doc)
          obj = CorporaObject.find_by_pid self.pid
          collections = obj.collections
          collections.each do |collection|
            titleize_and_index_single(solr_doc, 'corpora_collection', collection.title, :facetable)
            titleize_and_index_single(solr_doc, 'corpora_collection', collection.title, :stored_searchable)
          end

      end

      def add_to_corpora_objects solr_doc
#        2.0.0p195 :003 > CorporaObject.new({pid:"tufts:1",title:"blah",legacy:true})
 #        => #<CorporaObject id: nil, pid: "tufts:1", title: "blah", video: nil, transcript: nil, temporal: nil, creator: nil, collection_id: nil, media_type_id: nil, published: nil, legacy: true, created_at: nil, updated_at: nil>
  #      2.0.0p195 :004 >
        obj = CorporaObject.find_by_pid(solr_doc[:pid_ssi])
        unless obj
          #"http://bucket01.lib.tufts.edu/data05/tufts/central/dca/sample/access_mp3/AndreBeteilleFull.mp3"
          #"TuftsAudioText" self.class.to_s
          obj = CorporaObject.new({pid:self.pid,title:self.title,temporal:self.temporal[0],creator:self.creator[0], published:true,legacy:true})
          obj.save

        end
      end

      private

     def index_additional_terms solr_doc
       AnnotationTools.tag_overrides(self.pid.to_s,solr_doc)
     end
     def index_utterance_metadata solr_doc
          AnnotationTools.tag_things(self.pid.to_s,self,false,solr_doc)
          AnnotationTools.tag_things(self.pid.to_s,self,true)
          solr_doc
     end
  end
end
