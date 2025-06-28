
helm.add:
	helm repo add zitadel https://charts.zitadel.com || true
	helm repo add postgres https://charts.bitnami.com/bitnami || true

helm.update:
	helm repo update zitadel
	helm repo update postgres

helm.render: helm.add helm.update helm.render.zitadel

helm.render.zitadel:
	rm -rf ./bases/zitadel/rendered
	helm template zitadel zitadel/zitadel  --values ./values/zitadel/zitadel.values.yaml --output-dir ./bases/zitadel/rendered
	helm template postgres postgres/postgresql --values ./values/zitadel/postgres.values.yaml --output-dir ./bases/zitadel/rendered

render: helm.render

apply:
	kubectl apply -k overlays/

delete:
	kubectl delete -k overlays/
