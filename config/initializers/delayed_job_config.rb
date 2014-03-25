# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?

# Used to fix delayed_jobs
#
# Need to be able to serialize/deserialize AR objects that may not
# have a matching record in the database (unsaved or deleted) and delayed_job
# kills this ability unnecessarily.
if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do
    if instance_methods.include?(:encode_with_without_override)
      alias_method :encode_with, :encode_with_without_override
      remove_method :encode_with_override
      remove_method :encode_with_without_override
    end
  end
end