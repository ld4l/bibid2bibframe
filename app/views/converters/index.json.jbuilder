json.array!(@converters) do |converter|
  json.extract! converter, :bibid, :marcxml, :bibframe
  json.url converter_url(converter, format: :json)
end
