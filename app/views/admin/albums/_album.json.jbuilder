json.id album.id
json.title album.title
json.password album.password
json.published_at album.published_at
json.date_event album.date_event

json.images album.images do |image|
  json.id image.id
  json.url rails_blob_url(image, disposition: "attachment", only_path: true)
end
