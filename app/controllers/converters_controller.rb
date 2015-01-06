class ConvertersController < ApplicationController

  # Define the default RDF serialization for the application.
  # Note that this should not be left to the model. If there are multiple
  # converter models for different input formats, we don't want each one to
  # define its default output serialization.
  DEFAULT_SERIALIZATION = 'rdfxml'
  
  before_action :add_serialization, only: [:index]
    
  # GET /converters
  # GET /converters.json
  def index  
    @converter = Converter.new params
  end
  
  # GET /convert
  # GET /convert.json
  def convert 

    config = {
      # TODO Maybe better to add this to a config file or a form input field.
      :baseuri => 'http://ld4l.library.cornell.edu/',     
    }.merge(converter_params).symbolize_keys!

    @converter = Converter.new config

    respond_to do |format|     
      if @converter.valid?  
        @converter.convert 
        if @converter.download == '1'
          # return is necessary to prevent ActionController::UnknownFormat error 
          download and return 
        else 
          format.html { render :show }
          format.json { render :show, status: :created, location: @converter }
        end
      else
        format.html { render :index } 
        format.json { render json: @converter.errors, status: :unprocessable_entity }
      end
    end
  end

  # Use for testing
  # def test
  # end
  
  # GET /converter
  # GET /converter.json
  def show
  end
  
    
  private
  
    def download
      case @converter.serialization
        when 'rdfxml', 'rdfxml-raw'
          ext = 'rdf'
          mime_type = 'application/rdf+xml'
        when 'ntriples'
          ext = 'nt'
          mime_type = 'text/plain'
        when 'json'
          ext = 'js' 
          mime_type = 'application/javascript'
        # when 'turtle'
        #   ext = 'ttl'
        #   mime_type = 'application/x-turtle'      
      end
      serialization = @converter.serialization == 'rdfxml-raw' ? 'cascaded-rdfxml' : @converter.serialization
      filename = @converter.bibid + '_' + serialization + '_' + Time.now.strftime('%Y%m%d-%H%M%S') + '.' + ext
      send_data @converter.bibframe, filename: filename, type: '', disposition: 'attachment'           
    end
 
    def add_serialization
      params[:serialization] = DEFAULT_SERIALIZATION unless params[:serialization]
      params
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def converter_params
      params.require(:converter).permit(:bibid, :serialization, :download)
    end
end
