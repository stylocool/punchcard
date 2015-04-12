json.company do
  json.id @company.id
  json.name @company.name
  json.time @server_time
  json.projects @company.projects do |project|
    json.id project.id
    json.name project.name
    json.location project.location
  end
end