# TODO Can't get this to work from lib directory due to lib code being cached.
# Have tried most online solutions. Temporarily put the converter class here 
# until caching issues are resolved.
require 'active_model'
#require 'yaml'
  
# Try renaming to Bib2BibframeConverter
class Record

  include ActiveModel::Model
  
  attr_accessor :bibid, :format, :marcxml, :bibframe, :baseuri
  
  validates_numericality_of :bibid, only_integer: true, greater_than: 0, message: 'invalid: please enter a positive integer'  

  def initialize config
    
    # Breaks encapsulation, allowing the caller to determine the object's 
    # attributes
    # config.each {|k,v| instance_variable_set("@#{k}",v)}
    @baseuri = config[:baseuri]
    @bibid = config[:bibid] 
    @format = config[:format]
    
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
    
      # The LC Bibframe converter requires retrieving the marcxml from a file
      # rather than a variable, so we must write the result out to a temporary
      # file.
      xmlfile = File.join(Rails.root, 'log','marcxml.xml')
      File.write(xmlfile, @marcxml)  
     
      @bibframe = %x(java -cp #{saxon} net.sf.saxon.Query #{xquery} marcxmluri=#{xmlfile} baseuri=#{@baseuri} serialization=#{@format})
      
      File.delete(xmlfile)   
    else 
      @marcxml = 'No catalog record found for bibid ' + @bibid
    end
  end
end
