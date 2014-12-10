json.array!(@records) do |record|
  json.extract! record, :id, :bibid, :marcxml, :bibframe
  json.url record_url(record, format: :json)
end
