require 'fileutils'
require 'shellwords'
require 'open3'
class IngestsController < ApplicationController
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  before_filter :authenticate_user!

  protect_from_forgery

  def index

  end

  def execute_command(command)
    logger.info('Command is ' + command + '.')
    success = false
    error_msg = ''

    Open3.popen3(command) { |stdin, stdout, stderr, wait_thread|


      success = !wait_thread.nil? && wait_thread.value.success?
      stdin.close
       @info_msg = stdout.read
       stdout.close
       @error_msg = stderr.read
       stderr.close
    }

    unless success
      logger.error($PROGRAM_NAME + ": ffmpeg error on command \n" + command + "\n" + @error_msg)
    end

    return success
  end

  def create


    tmp = params[:file_upload][:my_file].tempfile
    FileUtils.mkdir_p(Rails.root + "public/dropbox")
    file = File.join(Rails.root + "public/dropbox", params[:file_upload][:my_file].original_filename)
    FileUtils.cp tmp.path, file
    # YOUR PARSING JOB
    #doc   = Nokogiri::XML(File.read(file))
    #xslt  = Nokogiri::XSLT(File.read(Rails.root + "xslt/v2t_tei.xsl"))
    #transformed_data = xslt.transform(doc)
    xslt_path = Rails.root.to_s + "/xslt"
    xslt_file = Rails.root.to_s + "/xslt/v2t_tei.xsl"
    output_file = file + ".xml"
    command = 'java -cp ' + xslt_path.to_s + '/saxon.jar:' + xslt_path.to_s + '/xmlenc-0.52.jar:' + xslt_path.to_s + '/ com.icl.saxon.StyleSheet ' + file.to_s.shellescape + ' ' + xslt_file.to_s + '> ' + output_file.to_s.shellescape
    puts command
    @success = execute_command command
    @download_link = output_file.gsub(Rails.root.to_s + '/public',"")

    #xslt = XML::XSLT.new()

    #xslt.xml = REXML::Document.new File.read(file)
    #xslt.xsl = REXML::Document.new File.read(Rails.root + "xslt/v2t_tei.xsl")
    #transformed_data  = xslt.serve()
    #File.open(file.to_s + ".xml" , 'w') {|f| f.write(transformed_data) }
    #FileUtils.rm file


  end
  ##  def create
  ##  require 'fileutils'
  ##   tmp = params[:file_upload][:my_file].tempfile
  ##   file = File.join("public", params[:file_upload][:my_file].original_filename)
  ##   FileUtils.cp tmp.path, file
  ##   # YOUR PARSING JOB
  ##   FileUtils.rm file
  ##end

end
