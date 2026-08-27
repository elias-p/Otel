# Multi‑Platform Observability Demo  
A Vendor‑Agnostic, Production‑Inspired Observability Platform

---

## 🚀 Overview

This project demonstrates a complete, end‑to‑end observability architecture integrating:

- OpenTelemetry Demo  
- OTel Collector  
- Cribl Stream  
- Elastic Observability  
- Grafana Loki / Tempo / Mimir  
- AWS Lambda telemetry processor  
- Dynatrace OTLP ingest  

It is designed to showcase senior‑level SRE and Observability Engineering skills in a modern,
multi‑cloud environment.

---

## 🎯 What This Project Demonstrates

- Multi‑vendor observability design  
- Distributed tracing correlation  
- Log/metric/trace normalization  
- Cribl pipeline engineering  
- Multi‑sink routing  
- Elastic + Grafana + Dynatrace integration  
- Serverless telemetry ingestion  
- Production‑grade architecture patterns  

---

## 🧩 Architecture Summary

1. **OTel Demo** generates logs, metrics, traces  
2. **OTel Collector** receives OTLP and fans out  
3. **Cribl Stream** enriches and routes telemetry  
4. Cribl sends data to:
   - Elastic (logs/metrics/traces)  
   - Loki (logs)  
   - Tempo (traces)  
   - Mimir (metrics)  
   - AWS Lambda (custom processing)  
   - Dynatrace (OTLP traces)  
5. Grafana visualizes logs/metrics/traces  
6. Elastic APM shows distributed traces  
7. Lambda prints telemetry  
8. Dynatrace ingests traces  

---

## 📦 Deployment Options

### Docker Compose

