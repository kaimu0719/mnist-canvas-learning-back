json.status "ok"
json.data do
  json.extract! drawing, :id, :label, :created_at, :updated_at
  if drawing.image.attached?
    json.image do
      json.content_type drawing.image.content_type
      json.byte_size drawing.image.byte_size
      json.url url_for(drawing.image)
    end
  else
    json.image nil
  end
end
