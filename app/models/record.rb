require 'active_model'

class Record 
  include ActiveModel::Model
  
  attr_accessor :bibid, :marcxml, :rdf
  
  validates_numericality_of :bibid, only_integer: true, greater_than: 0, message: 'invalid bib id: please enter a positive integer'
end
