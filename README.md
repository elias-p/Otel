# Multi
‑Platform Observability Demo  
A senior‑level observability engineering showcase integrating:

- OpenTelemetry Demo  
- Cribl Stream  
- Grafana Stack (Loki, Tempo, Mimir)  
- Elastic Observability  
- AWS Lambda  
- Dynatrace (OTLP ingest only)

This project demonstrates multi‑vendor observability routing, pipeline engineering, distributed tracing, log/metric correlation, and multi‑sink telemetry fan‑out.

---

## 📐 Architecture

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


🚀 How to Run
./installer.sh
scripts/otel-demo.sh

🎯 Skills Demonstrated
Multi‑vendor observability architecture

Cribl pipeline engineering

Distributed tracing correlation

Log/metric/trace fan‑out

AWS Lambda telemetry processing

Elastic + Grafana + Dynatrace integration

Senior‑level SRE / Observability engineering

🧪 Demo Workflow
Run installer

Start OTel Demo

Cribl receives telemetry

Grafana dashboards light up

Elastic APM shows traces

Lambda logs show telemetry processing




