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
       response = solr_connection.get 'select', :params => {:q => '*:*',:rows=>'10000000',:fl => 'pid_ssi', "group.field"=>'pid_ssi', :group=>'true'}
       results_array = response['grouped']['pid_ssi']['groups']

       #2 elementhash groupedValue=>pid  and docList

       results_array.each {|result|
         puts
         id = result['groupValue']
         @document_fedora = TuftsBase.find(id, :cast=>true)
         @document_fedora.update_index
       }
     end
   end

   handle_asynchronously :reindex_objects

end