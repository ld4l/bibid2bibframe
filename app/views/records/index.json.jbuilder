json.array!(@records) do |record|
  json.extract! record, :bibid, :marcxml, :bibframe
  json.url record_url(record, format: :json)
end
