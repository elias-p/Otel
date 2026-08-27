#!/bin/bash

echo "🚀 Building Multi‑Observability Demo Project Structure..."

# Create folders
mkdir -p scripts
mkdir -p aws
mkdir -p cribl/pipelines
mkdir -p grafana/dashboards

########################################
# ROOT FILES
########################################

cat > README.md << 'EOF'
# Multi‑Platform Observability Demo

A complete, vendor‑agnostic observability showcase integrating:

- OpenTelemetry Demo
- Cribl Stream
- Grafana (Loki, Tempo, Mimir)
- Elastic Observability
- AWS Lambda
- Dynatrace (OTLP only)

This project demonstrates senior‑level SRE, observability, and platform engineering skills.

## 📁 Project Structure
scripts/
aws/
cribl/
grafana/
EOF

cat > README-OTEL-DEMO.md << 'EOF'
# OpenTelemetry Demo → Multi‑Platform Observability Integration

Integrates OTel Demo with:
- Grafana Loki, Tempo, Mimir
- Cribl Stream
- Elastic Observability
- AWS Lambda
- Dynatrace OTLP (external only)
EOF

cat > ARCHITECTURE.md << 'EOF'
# Architecture Overview

```mermaid
flowchart LR
    OTelDemo --> Cribl
    Cribl --> Elastic
    Cribl --> GrafanaLoki
    Cribl --> GrafanaTempo
    Cribl --> GrafanaMimir
    Cribl --> AWSLambda
    Cribl --> Dynatrace[(Dynatrace OTLP)]
    AWSLambda --> Cribl
EOF

cat > RECRUITER-ONE-PAGER.md << 'EOF'
# Multi‑Platform Observability Demo — Recruiter Summary
Platforms:

OTel Demo

Cribl Stream

Grafana Stack

Elastic Observability

AWS Lambda

Dynatrace OTLP

EOF

########################################
#    SCRIPTS
########################################

cat > scripts/otel-demo.sh << 'EOF'
#!/bin/bash
docker compose -f otel-demo/docker-compose.yaml up -d
echo "OpenTelemetry Demo started."
EOF

cat > scripts/generate_fake_data.sh << 'EOF'
#!/bin/bash
while true; do
echo "Generating synthetic trace..."
curl -X POST http://localhost:4318/v1/traces -d '{}'
sleep 2
done
EOF

########################################
#AWS
########################################

cat > aws/lambda_processor.py << 'EOF'
def handler(event, context):
print("Received telemetry:", event)
return {"status": "processed"}
EOF

########################################
#CRIBL
########################################

cat > cribl/routes.conf << 'EOF'
{
"routes": [
{
"name": "OTel to Multi",
"pipeline": "otel_to_multi",
"filter": "true"
}
]
}
EOF

cat > cribl/pipelines/otel_to_multi.yaml << 'EOF'
output:

elastic

loki

tempo

mimir

lambda

dynatrace
EOF

########################################
#GRAFANA
########################################

cat > grafana/dashboards/example-dashboard.json << 'EOF'
{
"title": "Observability Demo Dashboard",
"panels": []
}
EOF

echo "✅ Project structure created successfully!"

