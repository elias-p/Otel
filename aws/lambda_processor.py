def handler(event, context):
print("Received telemetry:", event)
return {"status": "processed"}
