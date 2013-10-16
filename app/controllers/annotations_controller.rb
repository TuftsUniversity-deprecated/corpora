class AnnotationsController < ApplicationController
  # GET /locations
  # GET /locations.json
  def index
    #@annotations = { :name => 'Annotator Store API', :version => '2.0.0'}
    @annotations = {
        :message => "Annotator Store API",
        :links => {
            :annotation => {
                :delete => {
                    :url => "http://annotateit.org/api/annotations/:id",
                    :desc => "Delete an annotation",
                    :method => "DELETE"
                },
                :create => {
                    :url => "http://annotateit.org/api/annotations",
                    :query => {
                        :refresh => {
                            :type => "bool",
                            :desc => "Force an index refresh after create (default: true)"
                        }
                    },
                    :desc => "Create a new annotation",
                    :method => "POST"
                },
                :update => {
                    :url => "http://annotateit.org/api/annotations/:id",
                    :query => {
                        :refresh => {
                            :type => "bool",
                            :desc => "Force an index refresh after update (default: true)"
                        }
                    },
                    :desc => "Update an existing annotation",
                    :method => "PUT"
                },
                :read => {
                    :url => "http://annotateit.org/api/annotations/:id",
                    :desc => "Get an existing annotation",
                    :method => "GET"
                }
            },
            :search => {
                :url => "http://annotateit.org/api/search",
                :desc => "Basic search API",
                :method => "GET"
            },
            :search_raw => {
                :url => "http://annotateit.org/api/search_raw",
                :desc => "Advanced search API -- direct access to ElasticSearch. Uses the same API as the ElasticSearch query endpoint.",
                :method => "GET/POST"
            }
        }
    }
    respond_to do |format|
      format.json { render json: @annotations }
    end
  end

  def list

  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: annotation }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  def search
    @annotations = Annotation.find_all_by_pid(params[:uri])
    @annotations_json = {}
    @annotations_array = []
    @annotations_json[:total] = @annotations.length
    @annotations.each_index { |i|

      @annotations_array[i] = @annotations[i].json
      @annotations_array[i][:id] = i
      @annotations_array[i][:annotator_schema_version] = 'v1.0'
      @annotations_array[i][:consumer] = 'anotateit'
      @annotations_array[i][:created] = '2011-05-24T18:52:08.036814'
      @annotations_array[i][:updated] = '2011-05-26T12:17:05.012544'

    }
    @annotations_json[:rows] = @annotations_array
    respond_to do |format|
      format.json { render json: @annotations_json }
    end
  end

  def token
    render text: "eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJ0dGwiOiA4NjQwMCwgImNvbnN1bWVyS2V5IjogImFubm90YXRlaXQiLCAiaXNzdWVkQXQiOiAiMjAxMy0wOS0yOVQwMzoxMjoyNSswMDowMCIsICJ1c2VySWQiOiAibWtvcmN5In0.OiHbrkuq-C_jstoFKGPqbGQDwR9bnao7QJBK24rHUIA"
  end

  # POST /locations
  # POST /locations.json
  def create
    @annotation = Annotation.new()
    @annotation.pid = params[:uri]
    @annotation.text = params[:text]
    #@annotations.concept = params[:tags]
    @annotation.json = params
    @annotation.save
    respond_to do |format|
      if @annotation.save
        format.html { redirect_to @annotation, notice: 'Annotation was successfully created.' }
        format.json { render json: @annotation, status: :created, location: @annotation }
      else
        format.html { render action: "new" }
        format.json { render json: @annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end
end
