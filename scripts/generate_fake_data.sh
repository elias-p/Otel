#!/bin/bash
while true; do
echo "Generating synthetic trace..."
curl -X POST http://localhost:4318/v1/traces -d '{}'
sleep 2
done
