json.status "ok"
json.data do
  json.prediction_log do
    json.id @prediction_log.id
    json.drawing_id @prediction_log.drawing_id
    json.job_id @prediction_log.job_id
    json.status @prediction_log.status
    json.answer @prediction_log.answer
  end
end
