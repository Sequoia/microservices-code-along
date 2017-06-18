# To deploy

0.  Create `books` Secrets
    -   Edit `make-secrets-example.sh`
    -   Run `make-secrets-example.sh`
    -   `kubectl get secrets books`
    
1.  Create webapp
    -   Deployment
    -   Check: `kubectl rollout status deployment webapp`
    -   Service

2.  Create Auth
    -   Deployment
    -   Service

2.  Create Reverse Proxy 
    -   Deployment
    -   Service (local: `NodePort`, GKE: `LoadBalancer`)
    -   Get IP of service
        -   local: (`minikube service list`)
        -   remote: (`kubectl get nodes`)