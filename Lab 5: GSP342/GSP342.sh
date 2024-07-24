nano orca_storage_editor_410.yaml

title: "orca_storage_editor_410"
description: "Edit access for storage"
stage: "ALPHA"
includedPermissions:
- storage.buckets.get
- storage.objects.get
- storage.objects.list
- storage.objects.update
- storage.objects.create

gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID \
--file orca_storage_editor_410.yaml

#Task 3:-
SERVICE_ACCOUNT=orca-private-cluster-640-sa
CUSTOM_SECURIY_ROLE=orca_storage_editor_410

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.viewer

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/logging.logWriter

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role projects/$DEVSHELL_PROJECT_ID/roles/$CUSTOM_SECURIY_ROLE

# Task 4. Create and configure a new Kubernetes Engine private cluster
REGION=us-east4
ZONE=$REGION-c
PROJECT_ID=qwiklabs-gcp-01-18ebd4008640
NETWORK_NAME=orca-build-vpc
SUBNET_NAME=orca-build-subnet
CLUSTER_NAME=orca-cluster-188
gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --node-locations $ZONE \
    --num-nodes 1 \
    --network $NETWORK_NAME \
    --subnetwork $SUBNET_NAME \
    --enable-master-authorized-networks \
    --enable-ip-alias \
    --enable-private-nodes \
    --enable-private-endpoint \
    --service-account $SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
    --master-authorized-networks 192.168.10.2/32 

# Task 5. Deploy an application to a private Kubernetes Engine cluster
REGION=us-east4
ZONE=$REGION-c
CLUSTER_NAME=orca-cluster-188
gcloud config set compute/zone $ZONE && \
gcloud container clusters get-credentials $CLUSTER_NAME --internal-ip && \
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin && \
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0 && \
kubectl expose deployment hello-server --name orca-hello-service --type LoadBalancer --port 80 --target-port 8080
