require 'active_support/all'

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

  # create a javascript function that initializes a javascript global variable
  #   with all the people data.  the value of the variable is an array of hashtables
  def self.show_people(people)
    result = people.to_json
    result = "function initPeople () {people = " + result + '};'
    return result
  end

  # create a javascript function that initializes a javascript global variable
  #   with all the concept data.  the value of the variable is an array of hashtables
  def self.show_concepts(concepts)
    result = concepts.to_json
    result = "function initConcepts () {concepts = " + result + '};'
    return result
  end

  # create a javascript function that initializes a javascript global variable
  #   with all the places data.  the value of the variable is an array of hashtables
  def self.show_places(places)
    result = places.to_json
    result = "function initPlaces () {places = " + result + '};'
    return result
  end


end