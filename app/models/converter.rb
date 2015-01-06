# TODO Can't get this to work from lib directory due to lib code being cached.
# Have tried most online solutions. Temporarily put the converter class here 
# until caching issues are resolved.
require 'active_model'

#  
# Class name: if we extend the app to other input/output formats, can either
# add that as an object attribute, in which case no renaming would be necessary, 
# or create separate classes for each type of conversion 
# (Marc2BibframeConverter, etc.)
#
class Converter

  include ActiveModel::Model
  
  # The LC converter also accepts EXHIBITjson format, but this only works as a
  # display format managed by the converter itself.
  # There is a conceptual difference between this constant and that defined in 
  # ApplicationHelper. Here the model defines what formats it accepts, while the
  # ApplicationHelper defines formats for the views and controllers, including
  # their human-readable labels. Validation must occur against the model's
  # valid formats, whereas the application might deal with other formats in
  # addition.
  SERIALIZATION_FORMATS = %w(rdfxml rdfxml-raw ntriples json)
 
  # TODO Maybe not all need to be attr_accessor, only attr_reader or attr_writer
  # TEMP - :export shouldn't be a model attribute
  attr_accessor :bibid, :serialization, :baseuri, :marcxml, :bibframe, :export
  
  # TODO This needs to change when we accept an array of bibids
  validates_numericality_of :bibid, only_integer: true, greater_than: 0, message: 'invalid: please enter a positive integer' 
   
  validates_inclusion_of :serialization, in: SERIALIZATION_FORMATS, message: "%{value} is not a valid serialization format"
  

  def initialize config = {}
    
    # Breaks encapsulation, allowing the caller to determine the object's 
    # attributes
    # config.each {|k,v| instance_variable_set("@#{k}",v)}
    @baseuri = config[:baseuri]
    @bibid = config[:bibid] 
    @serialization = config[:serialization]
    @export = config[:export]
    @marcxml = ''
    @bibframe = ''

  end

  # TODO Add logging: set up logs (hard-coded initially, maybe later a config
  # option); set up arrays as temporary containers of log messages. Use a 
  # function log(message, :type) so that if there's no appropriate logfile 
  # defined OR the type of logging is set to false, no log is written (can still 
  # accumulate data in the log arrays, though.

  def convert
    
    # TODO Make the search url a config option? Could then be generalized to 
    # other catalogs, if the support the .marcxml extension
    marcxml = %x(curl -s http://newcatalog.library.cornell.edu/catalog/#{@bibid}.marcxml)

    if (marcxml.start_with?('<record'))

      marcxml << marcxml.gsub(/<record xmlns='http:\/\/www.loc.gov\/MARC21\/slim'>/, '<record>') 
      marcxml = "<?xml version='1.0' encoding='UTF-8'?><collection xmlns='http://www.loc.gov/MARC21/slim'>" + marcxml + "</collection>"
      # Pretty print the unformatted marcxml for display purposes
      @marcxml = `echo "#{marcxml}" | xmllint --format -`
      
      # Send the marcxml to the LC Bibframe converter
      # Marcxml to Bibframe conversion tools
      saxon = File.join(Rails.root, 'lib', 'saxon', 'saxon9he.jar')
      xquery = File.join(Rails.root, 'lib', 'marc2bibframe', 'xbin', 'saxon.xqy')
      
      tmpdir = File.join(Rails.root, 'tmp')
      
      # The LC Bibframe converter requires retrieving the marcxml from a file
      # rather than a variable, so we must write the result out to a temporary
      # file.
      xmlfile = File.join(tmpdir, 'marcxml.xml')
      File.write(xmlfile, @marcxml)  
      
      method = (@serialization == 'ntriples' || 
                @serialization == 'json') ? "'!method=text'" : ''
      
      @bibframe = %x(java -cp #{saxon} net.sf.saxon.Query #{method} #{xquery} marcxmluri=#{xmlfile} baseuri=#{@baseuri} serialization=#{@serialization})
      
      File.delete(xmlfile)   
    else 
       @bibframe = @marcxml = 'No catalog record found for bibid ' + @bibid    
    end
  end
end
