class ConvertersController < ApplicationController

  # GET /converters
  # GET /converters.json
  def index    
    @converter = Converter.new 
  end
  
  # GET /convert
  # GET /convert.json
  def convert 

    params = {
      # The application defines its default RDF serialization
      # TODO add a form field to select serialization
      # Valid formats (serializations supported by Bibframe converter):
      # rdfxml: (default) flattened RDF/XML, everything has an identifier
      # rdfxml-raw: verbose, cascaded output
      # ntriples, json, exhibitJSON
      #
      :serialization => 'rdfxml',
      # Might be better to add this to a config file or enter it on the form
      :baseuri => 'http://ld4l.library.cornell.edu/',     
    }.merge(converter_params).symbolize_keys!

    @converter = Converter.new params

    respond_to do |format|
      if @converter.valid?  
        @converter.convert 
        format.html { render :show }
        format.json { render :show, status: :created, location: @converter }
      else
        format.html { render :index } 
        format.json { render json: @converter.errors, status: :unprocessable_entity }
      end
    end
  end

  
  # GET /converter
  # GET /converter.json
  def show
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def converter_params
      params.require(:converter).permit(:bibid, :serialization)
    end
end
