# TODO Can't get this to work from lib directory due to lib code being cached.
# Have tried most online solutions. Temporarily put the converter class here 
# until caching issues are resolved.
require 'active_model'

if Rails.env == 'development'
  require 'pry-byebug'
end

#  
# Class name: if we extend the app to other input/output formats, can either
# add that as an object attribute, in which case no renaming would be necessary, 
# or create separate classes for each type of conversion 
# (Marc2BibframeConverter, etc.)
#
class Converter

  include ActiveModel::Model
  

  # There is a conceptual difference between this constant and that defined in 
  # ConvertersHelper. Here the model defines what formats it accepts, while the
  # ConvertersHelper defines formats for the views and controllers, including
  # their human-readable labels. Validation must occur against the model's
  # valid formats, whereas the application might deal with other formats in
  # addition.
  # The LC converter also accepts EXHIBITjson format, but this only works as a
  # display format managed by the converter itself.
  SERIALIZATION_FORMATS = %w(json ntriples rdfxml rdfxml-raw turtle)
  
  # TODO Should validate that the directories exist in lib dir
  CONVERTER_VERSIONS = %w(marc2bibframe-2015-11-05 marc2bibframe-2015-09-25 marc2bibframe-2015-06-24-delivery1)
  
  CATALOGS = %w(cornell harvard stanford)
 
  attr_reader :bibid, :bibframe, :catalog, :marc2bibframe, :marcxml, :serialization
  
  # TODO This needs to change when we accept an array of bibids
  validates_numericality_of :bibid, only_integer: true, greater_than: 0, message: 'invalid: please enter a positive integer' 
   
  validates_inclusion_of :serialization, in: SERIALIZATION_FORMATS, message: "%{value} is not a valid serialization format"
  
  validate :valid_catalog
  
  validate :bibid_in_catalog
  
  
  def initialize config = {}

    # Breaks encapsulation, allowing the caller to determine the object's 
    # attributes:
    # config.each {|k,v| instance_variable_set("@#{k}",v)}
    @baseuri = config[:baseuri]
    @marc2bibframe = config[:marc2bibframe]
    @serialization = config[:serialization]    
    @bibid = config[:bibid]
    @catalog = config[:catalog]

    @bibframe = ''
    @marcxml = ''

  end
  
  def valid_catalog
    if errors.empty?
      if ! CATALOGS.include? @catalog[:name]
        errors.add :catalog, 'invalid catalog'
      end
    end
  end
  
  def bibid_in_catalog
     
    # Don't look up bibid in catalog unless other validations have passed
    if errors.empty?
      
      url = @catalog[:url] + @bibid + @catalog[:url_extension]
      
      # curl options:
      # -s silent
      # -L follow 3xx redirect
      @marcxml = %x(curl -Ls #{url})
  
      if (! @marcxml.start_with?('<record'))    
        errors.add :bibid, 'invalid: not found in the catalog'
      end 
    end   
  end

  # TODO Add logging: set up logs (hard-coded initially, maybe later a config
  # option); set up arrays as temporary containers of log messages. Use a 
  # function log(message, :type) so that if there's no appropriate logfile 
  # defined OR the type of logging is set to false, no log is written (can still 
  # accumulate data in the log arrays, though.

  def convert



    @marcxml = @marcxml.gsub(/<record xmlns='http:\/\/www.loc.gov\/MARC21\/slim'>/, '<record>') 
    @marcxml = "<?xml version='1.0' encoding='UTF-8'?><collection xmlns='http://www.loc.gov/MARC21/slim'>" + @marcxml + "</collection>"
    # Pretty print the unformatted marcxml for display purposes
    @marcxml = `echo "#{@marcxml}" | xmllint --format -`
    
    # Send the marcxml to the LC Bibframe converter 
    # MARCXML to Bibframe conversion tools
    saxon = File.join(Rails.root, 'lib', 'saxon', 'saxon9he.jar')
    xquery = File.join(Rails.root, 'lib', @marc2bibframe, 'xbin', 'saxon.xqy')

    # The Saxon processor requires retrieving the marcxml from a file rather
    # than a variable or url, so we must write the result out to a temporary 
    # file. Zorba could be used instead to retrieve directly over http without
    # writing to a file. See https://github.com/lcnetdev/marc2bibframe.
    # However, when export is selected we need to write marxml to a file anyway.
    marcxml_file = Tempfile.new ['bibid2bibframe-convert-marcxml-', '.xml'] 
    # @bibframe = marcxml_file.path
    File.write(marcxml_file, @marcxml)  
    
    method = (@serialization == 'ntriples' || 
              @serialization == 'json') ? "'!method=text'" : ''

    turtle = @serialization == 'turtle' ? true : false
    @serialization = 'rdfxml' if turtle
         
    command = "java -cp #{saxon} net.sf.saxon.Query #{method} #{xquery} marcxmluri=#{marcxml_file.path} baseuri=#{@baseuri} serialization=#{@serialization}"
    @bibframe = %x(#{command})
    marcxml_file.close!
    
    if @bibframe.empty?
      @bibframe = "[CONVERTER ERROR: no BIBFRAME RDF returned]"
    end

    # LC Bibframe converter doesn't support turtle, so write Bibframe rdfxml
    # to a temporary file, convert to turtle, and read back into @bibframe.
    # TODO Can we avoid writing out the rdfxml and ttl to files? Try using
    # Tempfile class instead (see ConvertersController#export). Tried Ruby
    # rdf gems but it's not straightforward to get all prefixes into the
    # turtle.
    if turtle 
      @serialization = 'turtle'
      rdfxml_file = Tempfile.new ['bibid2bibframe-convert-rdfxml-', '.rdf']
      File.write(rdfxml_file, @bibframe)
      turtle_file = Tempfile.new ['bibid2bibframe-convert-ttl-', '.ttl'] 
      jarfile = File.join(Rails.root, 'lib', 'rdf2rdf-1.0.1-2.3.1.jar') 
      @bibframe = %x(java -jar #{jarfile} #{rdfxml_file.path} #{turtle_file.path})
      @bibframe = File.read turtle_file
      rdfxml_file.close!
      turtle_file.close!
    end

  end
end
