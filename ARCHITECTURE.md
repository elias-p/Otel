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
