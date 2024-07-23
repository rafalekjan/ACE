#Task 1. Create development VPC manually
gcloud compute networks create griffin-dev-vpc \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional
gcloud compute networks subnets create griffin-dev-wp \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --range=192.168.16.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-dev-vpc \
    --region=us-central1 
gcloud compute networks subnets create griffin-dev-mgmt \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --range=192.168.32.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-dev-vpc \
    --region=us-central1

#Task 2. Create production VPC manually
gcloud compute networks create griffin-prod-vpc \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional
gcloud compute networks subnets create griffin-prod-wp \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --range=192.168.48.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-prod-vpc \
    --region=us-central1 
gcloud compute networks subnets create griffin-prod-mgmt \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --range=192.168.64.0/20 \
    --stack-type=IPV4_ONLY \
    --network=griffin-prod-vpc \
    --region=us-central1

# Task 3. Create bastion host
gcloud compute instances create bastion-host \
    --project=qwiklabs-gcp-03-b09d87141a03 \
    --zone=us-central1-c \
    --machine-type=e2-micro \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=griffin-dev-mgmt \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=griffin-prod-mgmt \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=980661752106-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=bastion-host,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240709,mode=rw,size=10,type=projects/qwiklabs-gcp-03-b09d87141a03/zones/us-central1-c/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

gcloud compute --project=qwiklabs-gcp-03-b09d87141a03 \
    firewall-rules create griffin-fw-dev-22 \
    --direction=INGRESS \
    --priority=1000 \
    --network=griffin-dev-vpc \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
gcloud compute --project=qwiklabs-gcp-03-b09d87141a03 \
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
    --zone us-central1-c \
    --node-locations us-central1-c \
    --num-nodes 2 \
    --network "projects/qwiklabs-gcp-03-b09d87141a03/global/networks/griffin-dev-vpc" \
    --subnetwork "projects/qwiklabs-gcp-03-b09d87141a03/regions/us-central1/subnetworks/griffin-dev-wp" 

# Task 6. Prepare the Kubernetes cluster
gsutil -m cp -r gs://cloud-training/gsp321/wp-k8s .

# Task 7. Create a WordPress deployment
# Task 8. Enable monitoring
# Task 9. Provide access for an additional engineer
