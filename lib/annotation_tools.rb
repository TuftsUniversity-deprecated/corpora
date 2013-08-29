module AnnotationTools

  def self.create_regex records
    regex = "\\b("

    records.each do |record|

      regex += record.name
      regex += '|'
    end
    regex = regex[0..-2]
    regex += ")\\b"
    return regex
  end

  def self.tag_things pid, fedora_obj, index_blurbs, solr_doc=nil
    people = Person.all
    places = Location.all
    concepts = Concept.all
    # all = people + places + concepts

    node_sets = fedora_obj.datastreams['ARCHIVAL_XML'].find_by_terms_and_value(:u)
    node_sets.each do |node|
      utterence_id = node.attributes["n"]
      if index_blurbs
        solr_doc = {}
      end
      node.children.each do |child|
        childName = child.name
        if (childName == "u")
          #who = child.attributes["who"]

          blurb = Tufts::MediaPlayerMethods.parse_notations(child)

          unless people.size == 0
            regex = AnnotationTools.create_regex people
            match_data = blurb.match regex
            unless match_data.nil?
              match_data.captures.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                  Solrizer.insert_field(solr_doc, 'person', "#{data}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'names', "#{data}", :facetable)
                end
              end
            end
          end

          unless places.size == 0
            regex = AnnotationTools.create_regex places
            match_data = blurb.match regex
            unless match_data.nil?
              match_data.captures.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'place', "#{data}", :symbol)
                  Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'places', "#{data}", :facetable)
                end
              end
            end
          end

          unless concepts.size == 0
            regex = AnnotationTools.create_regex concepts

            match_data = blurb.match regex
            unless match_data.nil?
              match_data.captures.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'concepts', "#{data}", :symbol)
                  Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'concepts', "#{data}", :facetable)
                end
              end
            end
          end

          if index_blurbs
            Solrizer.insert_field(solr_doc, 'text', blurb, :stored_searchable)
          end
        elsif (childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic")
          unless child.attributes.empty?
            desc = child.attributes["desc"]
            unless desc.nil?
              # result << "                  <div class=\"transcript_row\">\n"
              # result << "                    <div class=\"transcript_speaker\">" "</div>\n"
              # result << "                    <div class=\"transcript_utterance\"><span class = \"transcript_notation\">["+ desc + "]</span></div>\n"
              # result << "                  </div> <!-- transcript_row -->\n"
            end
          end
        end
      end

      if index_blurbs
        Solrizer.insert_field(solr_doc, 'title', "Excerpt from " + fedora_obj.datastreams['DCA-META'].title[0], :stored_searchable)
        Solrizer.insert_field(solr_doc, 'pid', pid, :symbol)
        Solrizer.insert_field(solr_doc, 'has_model', 'info:fedora/afmodel:Snippet', :symbol)
        Solrizer.insert_field(solr_doc, 'read_access_group', 'public', :symbol)
        solr_doc.merge!(:id => pid + "-" + utterence_id)
        ActiveFedora::SolrService.add(solr_doc)
        ActiveFedora::SolrService.commit
      end


    end

    solr_doc
  end
end