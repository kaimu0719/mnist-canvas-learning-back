json.status "ok"
json.data @drawings do |drawing|
  json.id drawing.id
  json.label drawing.label

  if drawing.image.attached?
    json.image_url rails_blob_url(drawing.image, host: AppConstants::APP_URL)
  else
    json.image_url nil
  end
end
