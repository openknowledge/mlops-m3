kubectl create configmap demo-scripts --from-file=curl-drift.sh=../insurance-prediction/scripts/curl-drift.sh.gz

# Drift-Demo

To run the drift demo against the kubernetes cluster, use the following command:

```sh
kubectl create -f job.yaml
```

It creates a new kubernetes job that runs the prepared image `ghcr.io/habecker/insurance-prediction-drift-demo:latest`.
