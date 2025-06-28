
helm.add:
	helm repo add zitadel https://charts.zitadel.com || true
	helm repo add cockroachdb https://charts.cockroachdb.com || true

helm.update:
	helm repo update zitadel
	helm repo update cockroachdb

helm.render: helm.add helm.update helm.render.zitadel helm.render.cockroachdb

helm.render.zitadel:
	rm -rf ./bases/zitadel/templates
	helm template zitadel zitadel/zitadel  --values ./bases/zitadel/values.yaml --output-dir ./bases

helm.render.cockroachdb:
	rm -rf ./bases/cockroachdb/templates
	helm template cockroachdb cockroachdb/cockroachdb --output-dir ./bases

apply: helm.render
	kubectl apply -k overlays/

delete:
	kubectl delete -k overlays/
