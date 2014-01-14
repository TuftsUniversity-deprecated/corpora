module DelayedIndexing


   def after_save
     puts "Save record"
     reindex_objects

   end


   def reindex_objects
     pending_jobs = Delayed::Job.all
     pending_reindex = false
     pending_job_count = 0
     pending_jobs.each {|job|
       pending_job_count +=1 if job.handler[/reindex_objects/]
     }
     if pending_job_count < 2
       solr_connection = ActiveFedora.solr.conn

	#2.0.0-p0 :005 > CatalogController.blacklight_config[:default_solr_params][:qt]
	# => "search" 
	#2.0.0-p0 :006 > CatalogController.blacklight_config[:default_solr_params][:qf]
	# => "id creator_tesim title_tesim subject_tesim description_tesim identifier_tesim alternative_tesim contributor_tesim abstract_tesim toc_tesim publisher_tesim source_tesim date_tesim date_created_tesim date_copyrighted_tesim date_submitted_tesim date_accepted_tesim date_issued_tesim date_available_tesim date_modified_tesim language_tesim type_tesim format_tesim extent_tesim medium_tesim persname_tesim corpname_tesim geogname_tesim genre_tesim provenance_tesim rights_tesim access_rights_tesim rights_holder_tesim license_tesim replaces_tesim isReplacedBy_tesim hasFormat_tesim isFormatOf_tesim hasPart_tesim isPartOf_tesim accrualPolicy_tesim audience_tesim references_tesim spatial_tesim bibliographic_citation_tesim temporal_tesim funder_tesim resolution_tesim bitdepth_tesim colorspace_tesim filesize_tesim steward_tesim name_tesim comment_tesim retentionPeriod_tesim displays_tesim embargo_tesim status_tesim startDate_tesim expDate_tesim qrStatus_tesim rejectionReason_tesim note_tesim read_access_group_tim text_tesim" 
	#2.0.0-p0 :007 > 

       response = solr_connection.get 'select', :params => {:q => self.name, :qt => CatalogController.blacklight_config[:default_solr_params][:qt], :qf => CatalogController.blacklight_config[:default_solr_params][:qf], :rows=>'10000000',:fl => 'pid_ssi', "group.field"=>'pid_ssi', :group=>'true'}
       #response = solr_connection.get 'select', :params => {:q => 'manjapra',:rows=>'10000000',:fl => 'pid_ssi', :qf => '', "group.field"=>'pid_ssi', :group=>'true'}
       results_array = response['grouped']['pid_ssi']['groups']

       #2 elementhash groupedValue=>pid  and docList
logger.error("About to begin indexing #{results_array.length} results")
       results_array.each {|result|
         puts
         id = result['groupValue']
logger.error("Background indexing #{id} because it matched #{self.name}")
         @document_fedora = TuftsBase.find(id, :cast=>true)
         @document_fedora.update_index
       }
     end
   end

   handle_asynchronously :reindex_objects

end
