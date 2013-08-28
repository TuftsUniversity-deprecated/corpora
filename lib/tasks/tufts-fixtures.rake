ActiveFedora.init(:fedora_config_path => "#{Rails.root}/config/fedora.yml")
require "hydra"
require "active-fedora"
require 'csv'
require 'annotation_tools'

namespace :tufts do

  desc "Init Hydra configuration"
  task :init => [:environment] do
    # We need to just start rails so that all the models are loaded
  end

  desc "Load hydra-head models"
  task :load_models do
    require "hydra"
    puts "LOADING MODELS"
    #Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "..",'app','models', '*.rb')).each do |model|
    a = File.expand_path(File.dirname(__FILE__))
    puts "#{a}"
    Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), ".." ,"..",'app','models', '*.rb')).each do |model|
      load model
    end
  end

  namespace :sadl do

      # Checks and ensures task is not run in production.
      task :ensure_development_environment => :environment do
        if Rails.env.production?
          raise "\nI'm sorry, I can't do that.\n(You're asking me to drop your production database.)"
        end
      end

      # Custom install for developement environment
      desc "seed"
      task :seed => [:ensure_development_environment, "db:migrate", "tufts:sadl:populate_concepts","tufts:sadl:populate_people","tufts:sadl_populate_videourls"]

      # Populates development data
      desc "Populate the database with development data using CSV files. (video_urls)"
      task :populate_videourls => :environment do
        puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
        # Removes content before populating with data to avoid duplication
        # Rake::Task['db:reset'].invoke
        CSV.foreach(Rails.root + 'spec/fixtures/video_urls.csv') do |row|
          pid, mp4_link, webm_url, active = row
          # if the row already exists don't repeat it..
          unless VideoUrl.where(:pid => pid).count > 0
            puts "Adding #{pid} as a VideoURLs"
            VideoUrl.create!(:pid => pid, :mp4_link => mp4_link, :webm_url => webm_url, :active => active)
          end
        end

        puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
      end
      # Populates development data
      desc "Populate the database with development data using CSV files. (people)"
      task :populate_people => :environment do
        puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
        # Removes content before populating with data to avoid duplication
        # Rake::Task['db:reset'].invoke
        CSV.foreach(Rails.root + 'spec/fixtures/people.csv') do |row|
          name, description, link, alternative_names, image_link = row
          # if the row already exists don't repeat it..
          unless Person.where(:name => name).count > 0
            puts "Adding #{name} as a Person"
            Person.create!(:name => name, :description => description, :link => link, :alternative_names => alternative_names, :image_link => image_link)
          end
        end

        puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
      end

      # Populates development data
      desc "Populate the database with development data using CSV files. (concepts)"
      task :populate_concepts => :environment do
      	puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
        # Removes content before populating with data to avoid duplication
        # Rake::Task['db:reset'].invoke

        CSV.foreach(Rails.root + 'spec/fixtures/concepts.csv') do |row|
          name, description, link, alternative_names, image_link = row
          # if the row already exists don't repeat it..
          unless Concept.where(:name => name).count > 0
            puts "Adding #{name} as a Concept"
            Concept.create!(:name => name, :description => description, :link => link, :alternative_names => alternative_names, :image_link => image_link)
          end
        end

        puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
      end


    desc "Index Snippets from Transcript"
      task :index_snippets, [:pid] => :environment do |t, args|
        pid = args.pid
        video = TuftsVideo.find(pid)
        people = Person.all
        places = Location.all
        concepts = Concept.all
        all = people + places + concepts

        node_sets = video.datastreams['ARCHIVAL_XML'].find_by_terms_and_value(:u)
        node_sets.each do |node|
          utterence_id = node.attributes["n"]

          solr_doc = {}
          node.children.each do |child|
            childName = child.name
            if (childName == "u")
              who = child.attributes["who"]
              #result << "                  <div class=\"transcript_row\">\n"
              #result << "                    <div class=\"transcript_speaker\">"+ (who.nil? ? "" : who.value) + "</div>\n"
              #result << "                    <div class=\"transcript_utterance\">"+  Tufts::AudioMethods.parse_notations(child) + "</div>\n"
              blurb = Tufts::MediaPlayerMethods.parse_notations(child)

              unless people.size == 0
                regex = AnnotationTools.create_regex people
                match_data = blurb.match regex
                unless match_data.nil?
                  match_data.captures.each do |data|
                      Solrizer.insert_field(solr_doc, 'person', "#{data}", :symbol)
                      Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                  end
                end
              end

              unless places.size == 0
                regex = AnnotationTools.create_regex places
                match_data = blurb.match regex
                unless match_data.nil?
                  match_data.captures.each do |data|
                    Solrizer.insert_field(solr_doc, 'place', "#{data}", :symbol)
                    Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                  end
                end
              end

              unless concepts.size == 0
                regex = AnnotationTools.create_regex concepts

                match_data = blurb.match regex
                unless match_data.nil?
                  match_data.captures.each do |data|
                    Solrizer.insert_field(solr_doc, 'concepts', "#{data}", :symbol)
                    Solrizer.insert_field(solr_doc, 'thing', "#{data}", :symbol)
                  end
                end
              end

              Solrizer.insert_field(solr_doc, 'text', blurb, :stored_searchable)
              #result << "                  </div> <!-- transcript_row -->\n"
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



          Solrizer.insert_field(solr_doc, 'title', "Excerpt from " + video.datastreams['DCA-META'].title[0], :stored_searchable)
          Solrizer.insert_field(solr_doc, 'pid', pid, :symbol)
          Solrizer.insert_field(solr_doc, 'has_model', 'info:fedora/afmodel:Snippet', :symbol)
          Solrizer.insert_field(solr_doc, 'read_access_group','public',:symbol)
          solr_doc.merge!(:id => pid + "-" + utterence_id)
          ActiveFedora::SolrService.add(solr_doc)
          ActiveFedora::SolrService.commit



        end
      end

    namespace :fixtures do
      task :load do
        ENV["dir"] ||= "#{Rails.root}/spec/fixtures"
        loader = ActiveFedora::FixtureLoader.new(ENV['dir'])
        Dir.glob("#{ENV['dir']}/*.foxml.xml").each do |fixture_path|
          pid = File.basename(fixture_path, ".foxml.xml").sub("_",":")
          puts fixture_path
          begin
            foo = loader.reload(pid)
            puts "Updated #{pid}"
          rescue Errno::ECONNREFUSED => e
            puts "Can't connect to Fedora! Are you sure jetty is running? (#{ActiveFedora::Base.connection_for_pid(pid).inspect})"
          rescue Exception => e
            puts("Received a Fedora error while loading #{pid}\n#{e}")
            logger.error("Received a Fedora error while loading #{pid}\n#{e}")
          end
        end
      end

      desc "Remove default Hydra fixtures"
      task :delete do
        ENV["dir"] ||= "#{Rails.root}/spec/fixtures"
        loader = ActiveFedora::FixtureLoader.new(ENV['dir'])
        Dir.glob("#{ENV['dir']}/*.foxml.xml").each do |fixture_path|
          ENV["pid"] = File.basename(fixture_path, ".foxml.xml").sub("_",":")
          Rake::Task["repo:delete"].reenable
          Rake::Task["repo:delete"].invoke
        end
      end

      desc "Refresh default Hydra fixtures"
      task :refresh => [:delete, :load]
    end
  end
end

