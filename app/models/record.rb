require 'active_model'

class Record 
  include ActiveModel::Model
  
  attr_accessor :bibid, :marcxml, :bibframe
  
  validates_numericality_of :bibid, only_integer: true, greater_than: 0, message: 'invalid: please enter a positive integer'
  
  def convert
    self.marcxml = "this is the marcxml for bibid " + bibid
    self.bibframe = "this is the bibframe rdf for bibid " + bibid
  end
end
