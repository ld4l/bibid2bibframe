class ConvertersController < ApplicationController

  require 'zip'


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
        if @converter.export == '1'
          # return is necessary to prevent ActionController::UnknownFormat error 
          export and return 
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
  
    def export
      # TODO Define a hash to handle these
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
      
      # Filenames
      datetime = Time.now.strftime('%Y%m%d-%H%M%S')
      marcxml_filename = @converter.bibid + '_marcxml_' + datetime + '.xml' 
      
      serialization = ApplicationHelper::SERIALIZATION_FORMATS[@converter.serialization]
      base_filename = @converter.bibid + '_' + serialization[:file_label] + '_' + datetime
      bibframe_filename = base_filename + '.' + serialization[:file_extension]
      zip_filename = base_filename + '.zip'

      tempfile = Tempfile.new('tempfile_' + datetime)
      Zip::OutputStream.open(tempfile.path) do |zip|
        zip.put_next_entry(marcxml_filename)
        zip.print @converter.marcxml
        
        zip.put_next_entry(bibframe_filename)
        zip.print @converter.bibframe
      end     
      
      send_file tempfile.path, filename: zip_filename, type: 'application/zip', disposition: 'attachment'           
    end
 
    def add_serialization
      params[:serialization] = DEFAULT_SERIALIZATION unless params[:serialization]
      params
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def converter_params
      params.require(:converter).permit(:bibid, :serialization, :export)
    end
end
