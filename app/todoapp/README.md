# todoapp

Deployment of [jeffthorne/tasky](https://github.com/jeffthorne/tasky) (MIT licensed, vendored in `src/`) onto the AKS
cluster provisioned by the Terraform in the repo root, backed by the MongoDB VM also provisioned there.

## Layout

- `src/` — vendored app source + its `Dockerfile`. Unmodified from upstream except for what's needed to build.
- `k8s/namespace.yaml`, `k8s/deployment.yaml`, `k8s/service.yaml` — static manifests, no secrets. Safe to commit.

## How it deploys

`.github/workflows/deploy-todoapp.yml` (repo root — GitHub requires workflows to live there) builds the image with
`az acr build`, pushes it to ACR, and applies these manifests on every push to `main`/`dev` that touches `app/todoapp/**`.

The app needs two environment variables it doesn't get from the manifests directly — `MONGODB_URI` and `SECRET_KEY` —
sourced from a `todoapp-secrets` Kubernetes Secret that the **workflow creates at deploy time** from GitHub Actions
repo secrets (`MONGODB_PASSWORD`, `APP_SECRET_KEY`). The Secret is never written to a file in this repo.

## Running it manually (if you're not going through the workflow)

```bash
az acr build --registry acr2tierwizexercise2uv6ht --image todoapp:manual app/todoapp/src

kubectl apply -f app/todoapp/k8s/namespace.yaml

kubectl create secret generic todoapp-secrets -n todoapp \
  --from-literal=MONGODB_URI="mongodb://admin:<mongo-password>@10.0.1.4:27017/?authSource=admin" \
  --from-literal=SECRET_KEY="<any-random-string>" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f app/todoapp/k8s/deployment.yaml -f app/todoapp/k8s/service.yaml
kubectl set image deployment/todoapp todoapp=acr2tierwizexercise2uv6ht.azurecr.io/todoapp:manual -n todoapp
kubectl rollout status deployment/todoapp -n todoapp

kubectl get svc todoapp -n todoapp   # wait for EXTERNAL-IP
```

## Notes

- The app has no dedicated health-check endpoint upstream; the probes in `deployment.yaml` hit `GET /` (the login
  page), which confirms the process is up but not that it's actually connected to MongoDB.
- MongoDB's own database name (`go-mongodb`) is hardcoded in the app and gets created automatically on first write.
