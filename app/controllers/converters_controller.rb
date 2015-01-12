class ConvertersController < ApplicationController

  require 'zip'

  # Define the default RDF serialization for the application.
  # Note that this should not be left to the model. If there are multiple
  # converter models for different input formats, we don't want each one to
  # define its default output serialization.
  DEFAULT_SERIALIZATION = 'rdfxml'
  
  before_action :set_serialization, only: [:index]
    
  # GET /converters
  # GET /converters.json
  def index  
    @converter = Converter.new params   
  end
  
  # GET /convert
  # GET /convert.json
  def convert 
    
    config = {
      # TODO Better to add this to a config file or a form input field, or
      # both, with the form field overriding the default from the config file.
      :baseuri => 'http://ld4l.library.cornell.edu/',     
    }.merge(converter_params).symbolize_keys!
  
    @converter = Converter.new config

    respond_to do |format|     
      if @converter.valid?  
        @converter.convert 
        if params[:export] == '1'
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

      # Set filenames
      datetime = Time.now.strftime('%Y%m%d-%H%M%S')
      marcxml_filename = @converter.bibid + '_marcxml_' + datetime + '.xml' 
      
      serialization = ApplicationHelper::SERIALIZATION_FORMATS[@converter.serialization]
      base_filename = @converter.bibid + '_' + serialization[:file_label] + '_' + datetime
      bibframe_filename = base_filename + '.' + serialization[:file_extension]
      zip_filename = base_filename + '.zip'

      tempfile = Tempfile.new('bib2bibframe-export-')
        
      begin
        Zip::OutputStream.open(tempfile.path) do |zip|
          zip.put_next_entry(marcxml_filename)
          zip.print @converter.marcxml
          
          zip.put_next_entry(bibframe_filename)
          zip.print @converter.bibframe
        end     

        send_file tempfile.path, filename: zip_filename, type: 'application/zip', disposition: 'attachment'       
      ensure
        tempfile.close
        # Can't do this: file gets deleted before being offered for download. 
        # Doesn't work in an after_action (even if tempfile is stored in an
        # instance variable). Ruby's garbage collection should handle deletion
        # (although stdlib doc recommends explicit deletion anyway).
        # tempfile.unlink
      end
    end

    def set_serialization
      params[:serialization] ||= DEFAULT_SERIALIZATION
    end

    # Whitelist allowable params sent to the converter model as a security 
    # measure
    def converter_params
      params.require(:converter).permit(:bibid, :serialization)
    end
end
