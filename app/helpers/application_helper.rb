module ApplicationHelper

  SERIALIZATION_FORMATS = {
    'rdfxml' => {
      :file_extension => 'rdf',
      :file_label => 'rdfxml',
      :form_label => 'RDF/XML',
      :mime_type => 'application/rdf+xml',
    },
    'rdfxml-raw' => {
      :file_extension => 'rdf',
      :file_label => 'cascaded-rdfxml',
      :form_label => 'Cascaded RDF/XML',
      :mime_type => 'application/rdf+xml',
    },
    'json' => {
      :file_extension => 'js',
      :file_label => 'json',
      :form_label => 'JSON',
      :mime_type => 'application/javascript',
    },
    'ntriples' => {
      :file_extension => 'nt',
      :file_label => 'ntriples',
      :form_label => 'N-Triples',
      :mime_type => 'text/plain',      
    },
    # 'turtle' => {
    #   :file_extension => 'ttl',
    #   :file_label => 'turtle',
    #   :form_label => 'Turtle',
    #   :mime_type => 'application/x-turtle'
    # },    
  }

end
