ActiveFedora.init(:fedora_config_path => "#{Rails.root}/config/fedora.yml")
require "hydra"
require "active-fedora"
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

