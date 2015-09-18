ActiveFedora.init(:fedora_config_path => "#{Rails.root}/config/fedora.yml")
require 'hydra'
require 'active-fedora'
require 'csv'
require 'annotation_tools'

namespace :tufts do

  namespace :batch do

    desc 'Run Batch to add/delete people, concepts, places'
    task :run => :environment do
      if ENV['CONCEPTS_FILE']
        index_list = ENV['CONCEPTS_FILE']
      else
        puts 'rake tufts:batch:run CONCEPTS_FILE=/home/hydradm/some.csv'
        next
      end

      keys = [:action, :overwrite?, :primary_type, :authoritative_name, :description, :alternative_names, :image_link, :information_link, \
        :modern_location, :historical_name, :admin01, :admin02, :town, :latitude, :longitude, :location_type, :external_feature_id, :source_id, :variable_names]

      CSV.foreach(index_list, encoding: 'UTF-8') do |row|
        record = Hash[keys.zip(row)]
        action = record[:action]
        if action.downcase == 'add'
          add_item record
        elsif action.downcase == 'remove'
          remove_item record
        else
          puts "Unknown action #{action} for row: #{row}"
        end
      end

    end


    def remove_item(record)

      if record[:primary_type].downcase == 'person' || record[:primary_type].downcase == 'people'

        Person.where(:name => record[:authoritative_name]).destroy_all

      elsif record[:primary_type].downcase == 'concept'

        Concept.where(:name => record[:authoritative_name]).destroy_all

      elsif record[:primary_type].downcase == 'location'

        Location.where(:name => record[:authoritative_name]).destroy_all

      end
    end


    def add_item(record)

      primary_type = record[:primary_type]

      if primary_type.downcase == 'person' || primary_type.downcase == 'people'

        add_person record

      elsif primary_type.downcase == 'concept'

        add_concept record

      elsif primary_type.downcase == 'location'

        add_location record

      else

        puts "Ignoring row of type #{record[primary_type]}: #{record.to_s}"

      end

    end

    def add_location(record)
      exists = Location.where(:name => record[:authoritative_name]).count > 0 ? true : false
      overwrite = record[:overwrite].nil? ? false : to_bool(record[:overwrite].downcase)
      if exists && !overwrite
        puts "This row already exists, will not replace #{record[:authoritative_name]}."
      else
        puts "TODO : FIX ME"
      end
    end

    def add_concept record
      exists = Concept.where(:name => record[:authoritative_name]).count > 0 ? true : false
      overwrite = record[:overwrite].nil? ? false : to_bool(record[:overwrite].downcase)

      if exists && !overwrite
        puts "This row already exists, will not replace #{record[:authoritative_name]}."
      else
        Concept.create!(:name => record[:authoritative_name], :description => record[:description], :link => record[:information_link], :alternative_names => record[:alternative_names], :image_link => record[:image_link])
      end
    end

    def add_person(record)
      exists = Person.where(:name => record[:authoritative_name]).count > 0 ? true : false
      overwrite = record[:overwrite].nil? ? false : to_bool(record[:overwrite].downcase)
      if exists && !overwrite
        puts "This row already exists, will not replace #{record[:authoritative_name]}."
      else
        Person.create!(:name => record[:authoritative_name], :description => record[:description], :link => record[:information_link], :alternative_names => record[:alternative_names], :image_link => record[:image_link])
      end
    end

    def to_bool(str)
      str == 'true'
    end
  end
end


