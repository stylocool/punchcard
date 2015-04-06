json.punchcard do
  json.id @punchcard.id
  json.project do
    json.id @punchcard.project.id
    json.name @punchcard.project.name
  end
  json.worker do
    json.id @punchcard.worker.id
    json.name @punchcard.worker.name
  end
  if @punchcard.checkin.present?
    json.checkin_location @punchcard.checkin_location
    json.checkin @punchcard.checkin.strftime("%d %B %Y %H:%M:%S")
  end
  if @punchcard.checkout.present?
    json.checkout_location @punchcard.checkout_location
    json.checkout @punchcard.checkout.strftime("%d %B %Y %H:%M:%S")
  end
end