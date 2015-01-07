module ApplicationHelper

  # Add weights so display (e.g., in select lists) isn't dependent on the order 
  # in this list.
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
