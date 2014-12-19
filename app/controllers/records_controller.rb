class RecordsController < ApplicationController

  # GET /records
  # GET /records.json
  def index
    @record = Record.new
  end
  
  # GET /convert_records
  # GET /convert_records.json
  def convert 

    params = {
      # The application defines its default RDF serialization
      # TODO add a form field to select serialization
      # Valid formats (serializations supported by Bibframe converter):
      # rdfxml: (default) flattened RDF/XML, everything has an identifier
      # rdfxml-raw: verbose, cascaded output
      # ntriples, json, exhibitJSON
      #
      :format => 'rdfxml',
      # Might be better to add this to a config file or enter it on the form
      :baseuri => 'http://ld4l.library.cornell.edu/',     
    }.merge(record_params).symbolize_keys!

    @record = Record.new params

    respond_to do |format|
      if @record.valid?  
        @record.convert 
        format.html { render :show }
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :index } 
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /record
  # GET /record.json
  def show
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def record_params
      # TODO add :format here and enable format selection in the UI
      params.require(:record).permit(:bibid)
    end
end
