class RecordsController < ApplicationController

  # GET /records
  # GET /records.json
  def index
    @record = Record.new
  end
  
  # GET /convert_records
  # GET /convert_records.json
  def convert   
    @record = Record.new record_params

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
      # params.require(:record).permit(:bibid, :marcxml, :bibframe)
      params.require(:record).permit(:bibid)
    end
end
