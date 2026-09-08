Here’s a **single README.md** you can copy‑paste directly.

```markdown
# AWS Lambda + OpenTelemetry + Datadog (Python 3.11)

This README describes, step by step, how to:

- Build and package your Lambda code
- Configure environment variables (including OTLP → Datadog)
- Set the OpenTelemetry Lambda extension wrapper
- Deploy and invoke the function
- Verify logs and telemetry

---

## 1. Project layout

Your working directory (on the Ubuntu host):

```bash
~/lambda-new/lambda_src
```

Example contents:

```bash
__pycache__/
bin/
lambda_function.py
requirements.txt
opentelemetry/
opentelemetry_sdk-1.33.1.dist-info
opentelemetry_instrumentation-0.54b1.dist-info
opentelemetry_instrumentation_aws_lambda-0.54b1.dist-info
opentelemetry_proto-1.33.1.dist-info
opentelemetry_semantic_conventions-0.54b1.dist-info
opentelemetry_api-1.33.1.dist-info
requests/
urllib3/
...
```

Make sure **`lambda_function.py`** is in this folder.

---

## 2. Example `lambda_function.py` (manual OTel → Datadog)

> If you already have your own handler, you can adapt this.  
> This example sends **one span** and **one counter metric** to Datadog via OTLP HTTP/protobuf.

```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter

# --- Datadog OTLP HTTP/protobuf exporters ---
trace_exporter = OTLPSpanExporter(
    endpoint="https://api.datadoghq.com/api/v2/otlp",
    headers={"DD-API-KEY": "YOUR_DATADOG_API_KEY"},
)

metric_exporter = OTLPMetricExporter(
    endpoint="https://api.datadoghq.com/api/v2/otlp",
    headers={"DD-API-KEY": "YOUR_DATADOG_API_KEY"},
)

# --- Providers and global registration ---
trace_provider = TracerProvider()
trace_provider.add_span_processor(BatchSpanProcessor(trace_exporter))
trace.set_tracer_provider(trace_provider)

metric_reader = PeriodicExportingMetricReader(metric_exporter)
metric_provider = MeterProvider(metric_readers=[metric_reader])
metrics.set_meter_provider(metric_provider)

tracer = trace.get_tracer("otel-demo")
meter = metrics.get_meter("otel-demo")
counter = meter.create_counter("otel_demo.counter")

def handler(event, context):
    with tracer.start_as_current_span("otel-demo-span"):
        counter.add(1)
        return {
            "statusCode": 200,
            "body": "Hello from OpenTelemetry + Datadog"
        }
```

**Replace** `YOUR_DATADOG_API_KEY` with your real key.

---

## 3. Install dependencies into `lambda_src`

From your Ubuntu host:

```bash
cd ~/lambda-new/lambda_src

# Example: install requirements into the current folder
pip install -r requirements.txt -t .
```

This ensures all Python packages are inside `lambda_src` and will be included in the ZIP.

---

## 4. Create the deployment ZIP

From inside `lambda_src`:

```bash
cd ~/lambda-new/lambda_src

zip -r ../lambda.zip .
```

This creates:

```bash
~/lambda-new/lambda.zip
```

containing `lambda_function.py` and all dependencies.

---

## 5. Configure Lambda environment variables

First, see current variables:

```bash
aws lambda get-function-configuration \
  --function-name otel-demo \
  --query "Environment.Variables"
```

To **set** environment variables, use the full `Variables={...}` syntax (no `...` placeholder):

```bash
aws lambda update-function-configuration \
  --function-name otel-demo \
  --environment "Variables={\
OTEL_SERVICE_NAME=otel-demo,\
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf,\
DD_API_KEY=YOUR_DATADOG_API_KEY,\
DD_SITE=datadoghq.com,\
OTEL_EXPORTER_OTLP_CONTENT_TYPE=application/x-protobuf,\
OTEL_EXPORTER_OTLP_HEADERS=DD-API-KEY=YOUR_DATADOG_API_KEY,\
OTEL_EXPORTER_OTLP_ENDPOINT=https://api.datadoghq.com/api/v2/otlp,\
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://api.datadoghq.com/api/v2/otlp,\
OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=https://api.datadoghq.com/api/v2/otlp\
}"
```

> **Important:**  
> - No spaces inside `Variables={...}` except between key/value pairs if escaped properly.  
> - Every key must be `KEY=VALUE`.  
> - Replace `YOUR_DATADOG_API_KEY` with your real key.

---

## 6. Set the OpenTelemetry Lambda exec wrapper

If you are using the AWS OTel Lambda extension, you typically set:

```bash
AWS_LAMBDA_EXEC_WRAPPER=/opt/otel-instrument
```

To add this to the Lambda environment:

```bash
aws lambda update-function-configuration \
  --function-name otel-demo \
  --environment "Variables={\
OTEL_SERVICE_NAME=otel-demo,\
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf,\
DD_API_KEY=YOUR_DATADOG_API_KEY,\
DD_SITE=datadoghq.com,\
OTEL_EXPORTER_OTLP_CONTENT_TYPE=application/x-protobuf,\
OTEL_EXPORTER_OTLP_HEADERS=DD-API-KEY=YOUR_DATADOG_API_KEY,\
OTEL_EXPORTER_OTLP_ENDPOINT=https://api.datadoghq.com/api/v2/otlp,\
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://api.datadoghq.com/api/v2/otlp,\
OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=https://api.datadoghq.com/api/v2/otlp,\
AWS_LAMBDA_EXEC_WRAPPER=/opt/otel-instrument\
}"
```

> This overwrites all environment variables in one shot, so include **all** keys you need.

---

## 7. Deploy the new ZIP to Lambda

```bash
aws lambda update-function-code \
  --function-name otel-demo \
  --zip-file fileb:///home/ubuntu/lambda-new/lambda.zip
```

Wait for the command to complete; it will return the new version info.

---

## 8. Invoke the Lambda

Test invocation:

```bash
aws lambda invoke \
  --function-name otel-demo \
  --payload '{}' \
  output.json
```

Check `output.json`:

```bash
cat output.json
```

You should see the JSON response from your handler.

---

## 9. View CloudWatch logs

Tail logs:

```bash
aws logs tail /aws/lambda/otel-demo --follow
```

You should see lines like:

- `Launching OpenTelemetry Lambda extension`
- `Starting otelcol-lambda...`
- `Everything is ready. Begin running and processing data.`
- `START RequestId: ...`
- `END RequestId: ...`
- `REPORT RequestId: ...`

If your manual OTel code is active, you should also see exporter activity (depending on log level).

---

## 10. Verify in Datadog

In Datadog:

- **APM → Services**  
  - Look for service named `otel-demo` (or whatever you set in `OTEL_SERVICE_NAME`).
- **Traces → Explorer**  
  - Look for spans named `otel-demo-span`.
- **Metrics → Explorer**  
  - Look for metric `otel_demo.counter`.

If you see those, your Lambda → OTel → Datadog pipeline is working.

---

## 11. Common pitfalls

- **Bad `--environment` syntax**  
  - Must be: `Variables={KEY=VALUE,KEY2=VALUE2,...}`  
  - No `...` placeholder, no stray characters.
- **Missing `lambda_function.py` in ZIP**  
  - Always run `zip -r ../lambda.zip .` from inside `lambda_src`.
- **API key mismatch**  
  - `DD_API_KEY` env var and `DD-API-KEY` header must match your Datadog key.
- **Region / site mismatch**  
  - For `datadoghq.com` use the correct site for your account.

---

## 12. Quick recap

1. Put `lambda_function.py` and dependencies in `~/lambda-new/lambda_src`.
2. Install Python packages into that folder (`pip install -t .`).
3. Zip the folder: `zip -r ../lambda.zip .`.
4. Update Lambda environment with OTEL + Datadog vars and `AWS_LAMBDA_EXEC_WRAPPER`.
5. Deploy ZIP with `aws lambda update-function-code`.
6. Invoke Lambda and tail logs.
7. Confirm traces/metrics in Datadog.

```
