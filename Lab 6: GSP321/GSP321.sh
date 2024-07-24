#Task 1. Create development VPC manually
REGION=us-west1
ZONE=us-west1-a
PROJECT_ID=qwiklabs-gcp-04-73e92f7fec44
gcloud compute networks create griffin-dev-vpc \
    --project=$PROJECT_ID \
    --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional
gcloud compute networks subnets create griffin-dev-wp \
    --project=$PROJECT_ID \
    --range=192.168.16.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-dev-vpc \
    --region=$REGION
gcloud compute networks subnets create griffin-dev-mgmt \
    --project=$PROJECT_ID \
    --range=192.168.32.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-dev-vpc \
    --region=$REGION

#Task 2. Create production VPC manually
gcloud compute networks create griffin-prod-vpc \
    --project=$PROJECT_ID \
    --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional
gcloud compute networks subnets create griffin-prod-wp \
    --project=$PROJECT_ID \
    --range=192.168.48.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-prod-vpc \
    --region=$REGION
gcloud compute networks subnets create griffin-prod-mgmt \
    --project=$PROJECT_ID \
    --range=192.168.64.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-prod-vpc \
    --region=$REGION

# Task 3. Create bastion host
gcloud compute instances create bastion-host \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=griffin-dev-mgmt \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=griffin-prod-mgmt \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=bastion-host,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240709,mode=rw,size=10,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

gcloud compute --project=$PROJECT_ID \
    firewall-rules create griffin-fw-dev-22 \
    --direction=INGRESS \
    --priority=1000 \
    --network=griffin-dev-vpc \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
gcloud compute --project=$PROJECT_ID \
    firewall-rules create griffin-fw-prod-22 \
    --direction=INGRESS \
    --priority=1000 \
    --network=griffin-prod-vpc \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0

# Task 4. Create and configure Cloud SQL Instance
# ...
gcloud sql connect griffin-dev-db --user=root --quiet

CREATE DATABASE wordpress;
CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
FLUSH PRIVILEGES;


# Task 5. Create Kubernetes cluster
gcloud container clusters create "griffin-dev" \
    --zone $ZONE \
    --node-locations $ZONE \
    --num-nodes 2 \
    --network "projects/$PROJECT_ID/global/networks/griffin-dev-vpc" \
    --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/griffin-dev-wp" 

# Task 6. Prepare the Kubernetes cluster
gsutil -m cp -r gs://cloud-training/gsp321/wp-k8s .

# Task 7. Create a WordPress deployment
# Task 8. Enable monitoring
# Task 9. Provide access for an additional engineer
