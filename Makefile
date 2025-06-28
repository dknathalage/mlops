
helm.add:
	helm repo add zitadel https://charts.zitadel.com || true
	helm repo add postgres https://charts.bitnami.com/bitnami || true
	helm repo add community-charts https://community-charts.github.io/helm-charts || true

helm.update:
	helm repo update

helm.render: helm.add helm.update helm.render.zitadel helm.render.mlflow

helm.render.zitadel:
	rm -rf ./bases/zitadel/rendered
	helm template zitadel zitadel/zitadel  --values ./values/zitadel/zitadel.values.yaml --output-dir ./bases/zitadel/rendered
	helm template postgres postgres/postgresql --values ./values/zitadel/postgres.values.yaml --output-dir ./bases/zitadel/rendered

helm.render.mlflow:
	rm -rf ./bases/mlflow/rendered
	helm template mlflow community-charts/mlflow --values ./values/mlflow/mlflow.values.yaml --output-dir ./bases/mlflow/rendered
	helm template postgres postgres/postgresql --values ./values/mlflow/postgres.values.yaml --output-dir ./bases/mlflow/rendered

render: helm.render

apply:
	kubectl apply -k overlays/

delete:
	kubectl delete -k overlays/
