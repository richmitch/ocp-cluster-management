# stable-diffusion

Creates a project called 'stable-diffusion'.


1. Create data job (this is 12 GB of downloads), creates a PVC and a job to download model data.

```bash
oc apply -f create-data/app.yaml
```

2. Run Deployment

```bash
oc apply -f create-app/app.yaml
```
