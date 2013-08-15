ActiveFedora.init(:fedora_config_path => "#{Rails.root}/config/fedora.yml")
require "hydra"
require "active-fedora"
require 'csv'
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
      task :seed => [:ensure_development_environment, "db:migrate", "tufts:sadl:populate"]


      # Populates development data
      desc "Populate the database with development data using CSV files."
      task :populate => :environment do
      	puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
        # Removes content before populating with data to avoid duplication
        # Rake::Task['db:reset'].invoke

        CSV.foreach(Rails.root + 'spec/fixtures/people.csv') do |row|
          name,description,link,alternative_names,image_link = row
          # if the row already exists don't repeat it..
          unless Person.where(:name => name).count > 0
            puts "Adding #{name} as a Person"
            Person.create!(:name => name, :description => description, :link => link, :alternative_names => alternative_names, :image_link =>image_link)
          end
        end

        puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
      end


    desc "Index Snippets from Transcript"
      task :index_snippets, [:pid] => :environment do |t, args|
        pid = args.pid
        video = TuftsVideo.find(pid)

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
              Solrizer.insert_field(solr_doc, 'text', Tufts::AudioMethods.parse_notations(child), :stored_searchable)
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

