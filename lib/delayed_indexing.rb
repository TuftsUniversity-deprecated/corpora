module DelayedIndexing


  def after_save
    puts "Save record"
    reindex_objects

  end

  def before_destroy
    puts "destroy record"
    reindex_objects

  end


  def reindex_objects


    solr_connection = ActiveFedora.solr.conn

    response = solr_connection.get 'select', :params => {:q => self.name, :qt => CatalogController.blacklight_config[:default_solr_params][:qt], :qf => CatalogController.blacklight_config[:default_solr_params][:qf], :rows => '10000000', :fl => 'pid_ssi', "group.field" => 'pid_ssi', :group => 'true'}
    #response = solr_connection.get 'select', :params => {:q => 'manjapra',:rows=>'10000000',:fl => 'pid_ssi', :qf => '', "group.field"=>'pid_ssi', :group=>'true'}
    results_array = response['grouped']['pid_ssi']['groups']

    #2 elementhash groupedValue=>pid  and docList
    logger.error("About to begin indexing #{results_array.length} results")
    results_array.each { |result|
      puts
      id = result['groupValue']
      logger.error("Background indexing #{id} because it matched #{self.name}")
      @document_fedora = TuftsBase.find(id, :cast => true)
      @document_fedora.update_index
    }

  end

  handle_asynchronously :reindex_objects

end
