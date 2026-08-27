# Cribl Stream – Multi‑Platform Observability Demo

This document describes the Cribl configuration used in the multi‑observability demo, including
routes, pipelines, and multi‑sink fan‑out logic.

---

## 📁 Cribl File Structure

cribl/
├── routes.conf  
├── pipelines/  
│   └── otel_to_multi.yaml  
└── lambda_processor.py  

---

## 📌 routes.conf (Routing Rules)

This file defines how telemetry is routed to multiple destinations.

Example content:

- Match OpenTelemetry logs, metrics, and traces
- Send copies to:
  - Elastic
  - Grafana Loki
  - Grafana Tempo
  - Grafana Mimir
  - AWS Lambda
  - Dynatrace OTLP

Routing logic:

Route OpenTelemetry data to multiple destinations
{
"name": "otel_to_multi",
"filter": "event.type == \"otel\"",
"pipeline": "otel_to_multi",
"output": [
"elastic",
"loki",
"tempo",
"mimir",
"lambda",
"dynatrace"
]
}



---

## 📌 Pipeline: otel_to_multi.yaml

This pipeline performs:

- Basic normalization  
- Metadata enrichment  
- Trace/log correlation  
- Multi‑sink fan‑out  

Pipeline stages:

1. **Parse OTLP JSON**
2. **Add fields:**
   - `cribl.received_at`
   - `cribl.source`
3. **Normalize timestamps**
4. **Convert trace IDs to hex**
5. **Route to outputs**

Example snippet:


---

## 📌 Pipeline: otel_to_multi.yaml

This pipeline performs:

- Basic normalization  
- Metadata enrichment  
- Trace/log correlation  
- Multi‑sink fan‑out  

Pipeline stages:

1. **Parse OTLP JSON**
2. **Add fields:**
   - `cribl.received_at`
   - `cribl.source`
3. **Normalize timestamps**
4. **Convert trace IDs to hex**
5. **Route to outputs**

Example snippet:

processors:

type: eval
name: add_metadata
expr:
cribl.received_at: now()
cribl.source: event.source

type: timestamp
name: normalize_ts
field: event.timestamp




---

## 📌 AWS Lambda Telemetry Processor (lambda_processor.py)

Purpose:

- Receive telemetry from Cribl  
- Perform lightweight transformation  
- Print or forward to another service  

Example logic:

def handler(event, context):
print("Received telemetry:", event)
return {"status": "ok"}



---

## 📌 Outputs (Destinations)

Your Cribl instance sends data to:

### Elastic
- Logs  
- Metrics  
- Traces  

### Grafana Loki
- Logs  

### Grafana Tempo
- Traces  

### Grafana Mimir
- Metrics  

### AWS Lambda
- Custom processing  

### Dynatrace
- OTLP ingest  

---

## 🚀 How Cribl Works in This Demo

1. OTel Demo generates telemetry  
2. Cribl receives OTLP  
3. Cribl enriches and normalizes data  
4. Cribl fans out to **six** observability platforms  
5. Each platform receives the same telemetry in its native format  

This demonstrates **vendor‑agnostic observability engineering**.

---

## 🎯 Skills Demonstrated

- Cribl routing  
- Cribl pipeline engineering  
- Multi‑sink fan‑out  
- OTLP normalization  
- Distributed tracing correlation  
- Observability platform integration  

# Elastic Ingest Pipeline – Multi‑Platform Observability Demo

This pipeline normalizes OpenTelemetry logs, metrics, and traces before indexing into Elasticsearch.

---

## 📌 Pipeline Name
otel_ingest_pipeline

---

## 📌 Full Pipeline Definition
PUT _ingest/pipeline/otel_ingest_pipeline
{
  "description": "Normalize OTLP logs, metrics, traces",
  "processors": [
    {
      "set": {
        "field": "ingest.received_at",
        "value": "{{_ingest.timestamp}}"
      }
    },
    {
      "rename": {
        "field": "traceId",
        "target_field": "trace.id",
        "ignore_missing": true
      }
    },
    {
      "rename": {
        "field": "spanId",
        "target_field": "span.id",
        "ignore_missing": true
      }
    },
    {
      "date": {
        "field": "timestamp",
        "formats": ["ISO8601"],
        "target_field": "@timestamp",
        "ignore_failure": true
      }
    },
    {
      "remove": {
        "field": ["timestamp"],
        "ignore_missing": true
      }
    },
    {
      "script": {
        "source": """
          if (ctx?.attributes != null) {
            ctx.attributes_flat = new HashMap();
            for (entry in ctx.attributes.entrySet()) {
              ctx.attributes_flat[entry.getKey()] = entry.getValue();
            }
          }
        """
      }
    }
  ]
}



Grafana Logs Dashboard


{
  "title": "OTel Logs Overview",
  "panels": [
    {
      "type": "logs",
      "title": "All Logs",
      "datasource": "Loki",
      "targets": [
        { "expr": "{job=\"otel-demo\"}" }
      ]
    },
    {
      "type": "stat",
      "title": "Log Count",
      "datasource": "Loki",
      "targets": [
        { "expr": "count_over_time({job=\"otel-demo\"}[5m])" }
      ]
    }
  ]
}


⭐ Grafana Dashboards (Plain Text)
This includes three dashboards: Logs, Metrics, Traces.


{
  "title": "OTel Logs Overview",
  "panels": [
    {
      "type": "logs",
      "title": "All Logs",
      "datasource": "Loki",
      "targets": [
        { "expr": "{job=\"otel-demo\"}" }
      ]
    },
    {
      "type": "stat",
      "title": "Log Count",
      "datasource": "Loki",
      "targets": [
        { "expr": "count_over_time({job=\"otel-demo\"}[5m])" }
      ]
    }
  ]
}


📌 Grafana Metrics Dashboard



{
  "title": "OTel Metrics Overview",
  "panels": [
    {
      "type": "graph",
      "title": "CPU Usage",
      "datasource": "Mimir",
      "targets": [
        { "expr": "otelcol_process_cpu_seconds_total" }
      ]
    },
    {
      "type": "graph",
      "title": "Memory Usage",
      "datasource": "Mimir",
      "targets": [
        { "expr": "otelcol_process_resident_memory_bytes" }
      ]
    }
  ]
}





📌 Grafana Traces Dashboard


{
  "title": "OTel Traces Overview",
  "panels": [
    {
      "type": "traces",
      "title": "Service Map",
      "datasource": "Tempo",
      "targets": [
        { "query": "" }
      ]
    },
    {
      "type": "traces",
      "title": "Recent Traces",
      "datasource": "Tempo",
      "targets": [
        { "query": "" }
      ]
    }
  ]
}



⭐ CRIBL PACK (Plain Text)

# Cribl Pack – Multi‑Platform Observability Demo

This Cribl Pack contains:
- Routes
- Pipelines
- Output definitions
- Sample processors
- Metadata enrichment
- Multi‑sink fan‑out logic

Pack Name: otel_multi_observability

---

## 📁 Pack Structure

cribl-pack/
├── pack.json
├── routes/
│   └── otel_to_multi.json
├── pipelines/
│   └── otel_to_multi.yaml
└── outputs/
    ├── elastic.json
    ├── loki.json
    ├── tempo.json
    ├── mimir.json
    ├── lambda.json
    └── dynatrace.json

---

## 📌 pack.json

{
  "name": "otel_multi_observability",
  "version": "1.0.0",
  "description": "Multi-sink OTLP routing for Elastic, Grafana, Lambda, Dynatrace",
  "author": "eP"
}

---

## 📌 Route: otel_to_multi.json

{
  "name": "OTel → Multi",
  "filter": "event.type == \"otel\"",
  "pipeline": "otel_to_multi",
  "output": [
    "elastic",
    "loki",
    "tempo",
    "mimir",
    "lambda",
    "dynatrace"
  ]
}

---

## 📌 Pipeline: otel_to_multi.yaml

processors:
  - type: eval
    name: add_metadata
    expr:
      cribl.received_at: now()
      cribl.source: event.source

  - type: timestamp
    name: normalize_ts
    field: event.timestamp

  - type: eval
    name: trace_hex
    expr:
      trace.id: to_hex(event.traceId)
      span.id: to_hex(event.spanId)

  - type: passthru
    name: send_to_outputs

---

## 📌 Outputs

### Elastic
{
  "type": "elasticsearch",
  "url": "http://elastic:9200",
  "index": "otel-demo"
}

### Loki
{
  "type": "loki",
  "url": "http://loki:3100"
}

### Tempo
{
  "type": "tempo",
  "url": "http://tempo:3200"
}

### Mimir
{
  "type": "mimir",
  "url": "http://mimir:9009"
}

### Lambda
{
  "type": "http",
  "url": "http://lambda-processor:8080"
}

### Dynatrace
{
  "type": "http",
  "url": "https://dynatrace.example.com/api/v2/otlp"
}

---

## 🎯 Purpose

This Cribl Pack demonstrates:
- Multi‑sink routing  
- OTLP normalization  
- Distributed tracing correlation  
- Vendor‑agnostic observability engineering  
- Real‑world pipeline design  

⭐ AWS LAMBDA README (Plain Text)



# AWS Lambda Telemetry Processor – Observability Demo

This Lambda function receives telemetry forwarded from Cribl Stream and performs lightweight
processing before returning a status response.

---

## 📌 File: lambda_processor.py

def handler(event, context):
    print("Received telemetry:", event)
    return {"status": "ok"}

---

## 📌 Purpose

- Accept OTLP logs, metrics, traces from Cribl  
- Validate payload structure  
- Print telemetry for debugging  
- Return a simple JSON response  
- Demonstrate serverless observability integration  

---

## 📌 Deployment Steps

1. Create Lambda function:
   - Runtime: Python 3.10
   - Handler: lambda_processor.handler

2. Upload `lambda_processor.py`

3. Add permissions:
   - Allow Cribl to invoke Lambda
   - Allow CloudWatch logging

4. Test with sample event:
{
  "traceId": "abc123",
  "spanId": "def456",
  "message": "hello from Cribl"
}

---

## 📌 Cribl → Lambda Integration

Cribl Output Definition:

{
  "type": "http",
  "url": "https://lambda-url.amazonaws.com/default/otelProcessor",
  "method": "POST",
  "format": "json"
}

---

## 🎯 Skills Demonstrated

- Serverless telemetry ingestion  
- Cribl → Lambda integration  
- Lightweight event processing  
- Real‑world observability pipeline design  

⭐ OTel Collector Config (Plain Text)


# OpenTelemetry Collector – Multi‑Platform Observability Demo
# Receives OTLP → sends to Cribl, Elastic, Grafana, Dynatrace, Lambda

receivers:
  otlp:
    protocols:
      http:
      grpc:

processors:
  batch:
  memory_limiter:
    check_interval: 1s
    limit_mib: 400
  resource:
    attributes:
      - key: service.name
        action: insert
        value: otel-demo

exporters:
  # Send to Cribl
  otlphttp/cribl:
    endpoint: http://cribl:10090
    compression: none

  # Send to Elastic
  otlphttp/elastic:
    endpoint: http://elastic:9200
    compression: none

  # Send to Grafana Loki
  loki:
    endpoint: http://loki:3100/loki/api/v1/push

  # Send to Grafana Tempo
  otlphttp/tempo:
    endpoint: http://tempo:3200

  # Send to Grafana Mimir
  prometheusremotewrite:
    endpoint: http://mimir:9009/api/v1/push

  # Send to AWS Lambda (via HTTP)
  otlphttp/lambda:
    endpoint: https://lambda-url.amazonaws.com/default/otelProcessor
    compression: none

  # Send to Dynatrace
  otlphttp/dynatrace:
    endpoint: https://YOUR_ENV.live.dynatrace.com/api/v2/otlp
    headers:
      Authorization: Api-Token YOUR_DYNATRACE_TOKEN
    compression: none

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [otlphttp/cribl, otlphttp/tempo, otlphttp/dynatrace]

    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [prometheusremotewrite, otlphttp/cribl, otlphttp/elastic]

    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [loki, otlphttp/cribl, otlphttp/elastic]


⭐ Dynatrace OTLP Config (Plain Text)
# Dynatrace OTLP Configuration – Production Ready

# Dynatrace OTLP endpoint (no /v1/traces suffix)
OTEL_EXPORTER_OTLP_ENDPOINT=https://YOUR_ENV.live.dynatrace.com/api/v2/otlp

# Protocol required by Dynatrace
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

# Correct header format (Dynatrace rejects Bearer)
OTEL_EXPORTER_OTLP_HEADERS=Authorization=Api-Token YOUR_DYNATRACE_TOKEN

# Recommended resource attributes
OTEL_RESOURCE_ATTRIBUTES=service.name=otel-demo,cloud.provider=aws,cloud.region=us-east-1

# Sampling
OTEL_TRACES_SAMPLER=parentbased_always_on


⭐ Dynatrace Token Scopes (Required)

openTelemetryTrace.ingest
metrics.ingest
openpipeline:logs:ingest



