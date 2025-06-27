# Ory Kratos with Flux and Kustomize on Minikube

This repository contains the configuration to deploy [Ory Kratos](https://www.ory.sh/kratos/) as an authentication layer using Flux, Kustomize, and the official [Ory Helm Chart](https://k8s.ory.sh/helm/kratos.html) on Minikube.

## Prerequisites

- Minikube running
- Flux installed on your cluster
- kubectl configured to access your Minikube cluster

## Architecture

```
bases/kratos/           # Base Kratos configuration
├── kustomization.yaml  # Base kustomization
├── namespace.yaml      # Kratos namespace
├── helmrepository.yaml # Ory Helm repository
└── helmrelease.yaml    # Kratos Helm release

overlays/local-cluster/ # Local cluster overlay
├── kustomization.yaml  # Overlay kustomization
└── kratos-values-patch.yaml # Local development patches
```

## Deployment

### 1. Deploy to your Minikube cluster

```bash
# Apply the configuration using kubectl
kubectl apply -k overlays/local-cluster/
```

### 2. Wait for Flux to sync

```bash
# Watch the HelmRelease status
flux get helmreleases -n kratos-system

# Watch the pods
kubectl get pods -n kratos-system -w
```

### 3. Access Kratos

Once deployed, Kratos will be available on NodePort services:

```bash
# Get Minikube IP
minikube ip

# Access Kratos Public API (for end users)
# http://<minikube-ip>:30080

# Access Kratos Admin API (for administration)
# http://<minikube-ip>:30081
```

## Configuration

### Base Configuration

The base configuration includes:

- **Database**: SQLite (suitable for testing)
- **Identity Schema**: Email/Password authentication
- **Auto-migration**: Enabled for easy setup
- **Services**: NodePort for Minikube access

### Local Cluster Overrides

The local-cluster overlay adds:

- **Development mode**: Enabled
- **Debug logging**: For easier troubleshooting
- **CORS settings**: Configured for local development
- **Fixed NodePorts**: 30080 (public), 30081 (admin)

## Testing the Setup

### 1. Check if Kratos is running

```bash
# Check pods
kubectl get pods -n kratos-system

# Check services
kubectl get svc -n kratos-system

# Check HelmRelease
flux get helmreleases -n kratos-system
```

### 2. Test the APIs

```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Test Public API health
curl http://$MINIKUBE_IP:30080/health/ready

# Test Admin API health
curl http://$MINIKUBE_IP:30081/health/ready

# Get identity schemas
curl http://$MINIKUBE_IP:30081/schemas
```

### 3. Test User Registration Flow

```bash
# Initiate registration flow
curl -X GET http://$MINIKUBE_IP:30080/self-service/registration/api

# The response will contain a flow with form fields for user registration
```

## Customization

### Environment-specific Values

To customize for different environments:

1. Create new overlays in `overlays/<environment>/`
2. Create environment-specific patches
3. Deploy using `kubectl apply -k overlays/<environment>/`

### Database Configuration

For production, replace the SQLite DSN with a proper database:

```yaml
kratos:
  config:
    dsn: postgres://user:pass@host:5432/kratos
```

### SMTP Configuration

Configure real SMTP for email functionality:

```yaml
kratos:
  config:
    courier:
      smtp:
        connection_uri: smtps://user:pass@smtp.example.com:465/
```

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check if Flux is running and syncing
2. **Service not accessible**: Verify Minikube IP and NodePort configuration
3. **Database errors**: Check if auto-migration completed successfully

### Useful Commands

```bash
# Check Flux status
flux get all

# Check Kratos logs
kubectl logs -n kratos-system deployment/kratos -f

# Delete and redeploy
kubectl delete -k overlays/local-cluster/
kubectl apply -k overlays/local-cluster/
```

## Next Steps

1. **Frontend Integration**: Build a frontend application that uses Kratos APIs
2. **Database Migration**: Move to PostgreSQL for production
3. **Ingress Setup**: Configure ingress for external access
4. **Monitoring**: Add monitoring and alerting for Kratos
5. **Backup**: Set up database backup procedures

## References

- [Ory Kratos Documentation](https://www.ory.sh/docs/kratos/)
- [Ory Kratos Helm Chart](https://k8s.ory.sh/helm/kratos.html)
- [Flux Documentation](https://fluxcd.io/docs/)
- [Kustomize Documentation](https://kustomize.io/) 