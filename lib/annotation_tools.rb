module AnnotationTools

  def self.create_regex records
    regex = "\\b("

    records.each do |record|

      regex += Regexp.quote(record.name)
      regex += '|'
    end
    regex = regex[0..-2] if records.size > 0
    regex += ")\\b"
    return Regexp.new(regex)
  end

  def self.tag_overrides pid, solr_doc
   terms = Annotation.find_all_by_pid pid
   terms.each do |term|
     puts "#{term}"
     Solrizer.insert_field(solr_doc, 'thing', "#{term.term}", :symbol)
     if term.term_type == "Person"
       Solrizer.insert_field(solr_doc, 'person', "#{term.term}", :symbol)
       Solrizer.insert_field(solr_doc, 'names', "#{term.term}", :facetable)
     elsif term.term_type == "Location"
       Solrizer.insert_field(solr_doc, 'places', "#{term.term}", :facetable)
       Solrizer.insert_field(solr_doc, 'place', "#{term.term}", :symbol)
     elsif term.term_type == "Concept"
      Solrizer.insert_field(solr_doc, 'concepts', "#{term.term}", :facetable)
      Solrizer.insert_field(solr_doc, 'concepts', "#{term.term}", :symbol)
     end
   end
   solr_doc
  end

  def self.tag_things pid, fedora_obj, index_blurbs, solr_doc=nil
    people = Person.all
    places = Location.all
    concepts = Concept.all
    # all = people + places + concepts
    time_table = Tufts::MediaPlayerMethods.get_time_table(fedora_obj)

    node_sets = fedora_obj.datastreams['ARCHIVAL_XML'].find_by_terms_and_value(:u)
    node_sets.each do |node|
      utterence_id = node.attributes['n']
      start_id = node.attributes['start']
      if index_blurbs
        solr_doc = {}
      end
      node.children.each do |child|
        childName = child.name
        if (childName == "u")
          #who = child.attributes["who"]

          blurb = Tufts::MediaPlayerMethods.parse_notations(child)
          annotations = Annotation.where("pid = ? AND utterance = ?", pid, start_id.to_s)
          unless annotations.size == 0
                      annotations.each do |annotation|
                        if annotation.term_type == "Person"
                          Solrizer.insert_field(solr_doc, 'thing', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'person', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'names', "#{annotation.term}", :facetable)
                        end

                        if annotation.term_type == "Location"
                          Solrizer.insert_field(solr_doc, 'place', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'thing', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'places', "#{annotation.term}", :facetable)
                        end
                        if annotation.term_type == "Concept"
                          Solrizer.insert_field(solr_doc, 'concepts', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'thing', "#{annotation.term}", :symbol)
                          Solrizer.insert_field(solr_doc, 'concepts', "#{annotation.term}", :facetable)
                      end
                      end
          end
          unless people.size == 0
            regex = AnnotationTools.create_regex people
            match_data = blurb.scan regex
            unless match_data.nil?
              match_data.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'thing', "#{data[0]}", :symbol)
                  Solrizer.insert_field(solr_doc, 'person', "#{data[0]}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'names', "#{data[0]}", :facetable)
                end
              end
            end
          end

          unless places.size == 0
            regex = AnnotationTools.create_regex places
            match_data = blurb.scan regex
            unless match_data.nil?
              match_data.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'place', "#{data[0]}", :symbol)
                  Solrizer.insert_field(solr_doc, 'thing', "#{data[0]}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'places', "#{data[0]}", :facetable)
                end
              end
            end
          end

          unless concepts.size == 0
            regex = AnnotationTools.create_regex concepts

            match_data = blurb.scan regex
            unless match_data.nil?
              match_data.each do |data|
                if index_blurbs
                  Solrizer.insert_field(solr_doc, 'concepts', "#{data[0]}", :symbol)
                  Solrizer.insert_field(solr_doc, 'thing', "#{data[0]}", :symbol)
                else
                  Solrizer.insert_field(solr_doc, 'concepts', "#{data[0]}", :facetable)
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
        #stored_sortable actually used to be stored_groupable in this case but groupable doesn't exist and i'm not sure if it should.
        Solrizer.insert_field(solr_doc, 'pid', pid, :stored_sortable)
        Solrizer.insert_field(solr_doc, 'time', time_table[start_id.to_s][:time],:symbol)
        Solrizer.insert_field(solr_doc, 'display_time', time_table[start_id.to_s][:display_time],:symbol)
        Solrizer.insert_field(solr_doc, 'displays', 'corpora', :stored_searchable)
        Solrizer.insert_field(solr_doc, 'has_model', 'info:fedora/afmodel:Snippet', :symbol)
        Solrizer.insert_field(solr_doc, 'read_access_group', 'public', :symbol)
        solr_doc.merge!(:id => pid + "-" + utterence_id)
        ActiveFedora::SolrService.add(solr_doc)
        ActiveFedora::SolrService.commit
      end


    end

    unless index_blurbs
      Solrizer.insert_field(solr_doc, 'pid', pid, :stored_sortable)
    end

    solr_doc
  end
end