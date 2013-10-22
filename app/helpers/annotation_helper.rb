require 'active_support/all'
require 'rsolr'
require 'set'

# code to help with annotations and getting annotation data to the client
module AnnotationHelper

  # annotate key words with a link to javascript function to display linked item
  def self.annotate_chunks(chunks, records, javascript_function)
    regexp = create_regexp(records)
    replacement_text =  "<a href='javascript:" + javascript_function + "(\"\0\")'>\0</a>"
    chunks.each do |chunk|
      text = chunk.text
      changed_text = text.gsub(regexp, replacement_text)
      chunk.text = changed_text
    end
  end

  # create a regular expression to match the passed array of people or concepts, etc.
  # currently, this is done on the client in javascript, not here
  def self.create_regexp(records)
    pattern = "\b("
    records.each do |record|
      name = record.name
      pattern << name
      unless record == records.last
        pattern << '|'
      end
    end
    pattern << ")\b"
    return RegExp.new pattern
  end

  # create a javascript function that returns an array of hashtables
  #   with all the people data.
  def self.show_people(people)
    result = people.to_json
    result = "function initPeople () {return " + result + '};'
    return result
  end

  # create a javascript function that returns an array of hashtables
  #   with all the concept data.
  def self.show_concepts(concepts)
    result = concepts.to_json
    result = "function initConcepts () {return " + result + '};'
    return result
  end

  # create a javascript function returns an array of hashtables
  #   with all the places data.
  def self.show_places(places)
    result = places.to_json
    result = "function initPlaces () {return" + result + '};'
    return result
  end

  # query Solr to get all occurrences of the the passed term
  # return the docs in the solr response
  # used to obtain all the transcript segments for a term
  # will this scale?  what if the passed term is referenced hundreds of times?
  # what is the default number of items Solr will return?
  def self.get_references(thing)
    solr_connection = ActiveFedora.solr.conn
    response = solr_connection.get 'select', :params => {:q => 'thing_ssim:' + thing}

    docs = response['response']['docs']
    return docs
  end

  # iterate over the Solr docs and compute summary info needed for UI
  # return an array of hashes, each hash contains title, id and occurrence count
  # for testing purposes, this does not filter out the passed pid
  def self.summarize_external_references(pid, references)
    return_value = {}
    references.each{ |reference|
      lecture_id = reference['pid_ssim']
      summary = return_value[lecture_id]
      if (summary.nil?)
        title = reference['title_tesim'][0]
        summary = {count: 1, title: title, id: lecture_id}
        return_value[lecture_id] = summary
      else
        summary[:count] = summary[:count] + 1
      end
    }
    return return_value.values
  end

  def self.summarize_internal_references(pid, references)
    return_value = []
    references.each{ | reference|
      current_pid = reference['pid_ssim'][0]
      if (pid == current_pid)
        id = reference['id']
        dash = id.rindex '-'
        segment_number = id[dash + 1, id.size]
        text = reference['text_tesim'][0]
        start_in_milliseconds = reference['start_in_milliseconds']
        display_time_ssim = reference['display_time_ssim']
        summary = {segmentNumber: segment_number, text: text, start_in_milliseconds: start_in_milliseconds,
                   display_time_ssim: display_time_ssim}
        return_value << summary
      end
    }
    return return_value
  end

  # return a flat list of the concepts, places and people appearing in the passed pid
  def self.get_terms_flat(pid)
    return_value = Set.new
    solr_connection = ActiveFedora.solr.conn
    response = solr_connection.get 'select', :params => {:q => 'pid_ssim:' + pid, :fl => 'thing_ssim'}

    docs = response['response']['docs']
    docs.each { |current_doc|
      terms = current_doc['thing_ssim']
      terms.each { |term|
        return_value << term
      }
    }
    return return_value
  end

  # query solr and return all the concepts, people and places for the passed interview
  # return value is a hash with keys :concepts, :people and :places, the values are set objects
  def self.get_terms(pid)
    solr_connection = ActiveFedora.solr.conn
    # first, get all the Solr records for this pid
    response = solr_connection.get 'select', :params => {:q => 'pid_ssim:' + pid, :rows=>'10000000',:fl => 'concepts_ssim, person_ssim, place_ssim'}
    docs = response['response']['docs']

    concepts = Set.new
    people = Set.new
    places = Set.new

    # iterate over Solr documents adding found concepts, people and places to their corresponding sets
    docs.each { |current_doc|
      current_concepts = current_doc['concepts_ssim']
      unless current_concepts.nil?
        current_concepts.each { | concept |
          concepts << concept}
      end
      current_people = current_doc['person_ssim']
      unless current_people.nil?
        current_people.each { | person |
        people << person}
      end
      current_places = current_doc['place_ssim']
      unless current_places.nil?
        current_places.each { | place |
          places << place
        }
      end
    }
    # return a hash with the concepts, people and places
    return_value = {:concepts => concepts, :people => people, :places => places}
    return return_value
  end
end