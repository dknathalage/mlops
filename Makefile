
helm.add:
	helm repo add ory https://k8s.ory.sh/helm/charts || true
	helm repo add cockroachdb https://charts.cockroachdb.com || true

helm.update:
	helm repo update ory
	helm repo update cockroachdb

helm.render: helm.add helm.update helm.render.kratos helm.render.cockroachdb

helm.render.kratos: 
	rm -rf ./bases/kratos/templates
	helm template kratos ory/kratos --output-dir ./bases

helm.render.cockroachdb:
	rm -rf ./bases/cockroachdb/templates
	helm template cockroachdb cockroachdb/cockroachdb --output-dir ./bases

apply: helm.render
	kubectl apply -k overlays/

delete:
	kubectl delete -k overlays/
