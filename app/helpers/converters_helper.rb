module ConvertersHelper

  # Add weights so display (e.g., in select lists) isn't dependent on the order 
  # in this list.
  
  CATALOGS = {
    'cornell' => {
      :form_label => 'Cornell',
      :name => 'cornell',
      :baseuri => 'http://draft.ld4l.org/cornell/',
      :url => 'https://newcatalog.library.cornell.edu/catalog/',
      :url_extension => '.marcxml',
      :weight => 0, 
    }, 
    'harvard' => {
      :form_label => 'Harvard',
      :name => 'harvard',
      :baseuri => 'http://draft.ld4l.org/harvard/',
      :url => 'http://webservices.lib.harvard.edu/rest/marc/hollis/',
      :url_extension => '',
      :weight => 1,       
    },
    'stanford' => {
      :form_label => 'Stanford',
      :name => 'stanford',
      :baseuri => 'http://draft.ld4l.org/stanford/',
      :url => 'https://searchworks.stanford.edu/view/',
      :url_extension => '.marcxml',
      :weight => 2,       
    }, 
  }
  
  MARC2BIBFRAME_VERSIONS = {
    'marc2bibframe-2015-11-05' => {
      :form_label => '2015-11-05',
      :file_label => 'marc2bibframe-version-2015-11-05',
      :marc2bibframe => 'marc2bibframe-2015-11-05',
      :weight => 0,
    },
    'marc2bibframe-2015-09-25' => {
      :form_label => '2015-09-25',
      :file_label => 'marc2bibframe-version-2015-09-25',
      :marc2bibframe => 'marc2bibframe-2015-09-25',
      :weight => 1,
    },
    'marc2bibframe-2015-06-24-delivery1' => {
      :form_label => '2015-06-24 (version used in full catalog conversion)',
      :file_label => 'marc2bibframe-version-2015-06-24',
      :marc2bibframe => 'marc2bibframe-2015-06-24-delivery1',
      :weight => 2,
    },
  }
    
  SERIALIZATION_FORMATS = {
    'json' => {
      :file_extension => 'js',
      :file_label => 'json',
      :form_label => 'JSON',
      :mime_type => 'application/javascript',
      :weight => 4,
    },
    'rdfxml' => {
      :file_extension => 'rdf',
      :file_label => 'rdfxml',
      :form_label => 'RDF/XML',
      :mime_type => 'application/rdf+xml',
      :weight => 0,
    },
    'rdfxml-raw' => {
      :file_extension => 'rdf',
      :file_label => 'cascaded-rdfxml',
      :form_label => 'Cascaded RDF/XML',
      :mime_type => 'application/rdf+xml',
      :weight => 1,
    },
    'ntriples' => {
      :file_extension => 'nt',
      :file_label => 'ntriples',
      :form_label => 'N-Triples',
      :mime_type => 'text/plain',
      :weight => 2,      
    },
    'turtle' => {
      :file_extension => 'ttl',
      :file_label => 'turtle',
      :form_label => 'Turtle',
      :mime_type => 'application/x-turtle',
      :weight => 3,
    },    
  }


end
