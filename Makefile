
helm.add:
	helm repo add ory https://k8s.ory.sh/helm/charts

helm.update:
	helm repo update ory

helm.render: helm.add helm.update helm.render.kratos

helm.render.kratos: 
	helm template kratos ory/kratos --output-dir ./bases