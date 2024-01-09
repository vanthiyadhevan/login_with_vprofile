!/bin/bash

# Apply deployment
kubectl apply -f deployment.yaml

# Apply service
kubectl apply -f service.yaml

# Wait for the deployment to be ready
kubectl rollout status deployment vprofile-deployment
