export ZONE=us-west1-c
export INSTANCE_NAME=nucleus-jumphost-582
export MACHINE_TYPE=e2-micro

gcloud config set compute/zone $ZONE
gcloud compute instances create $INSTANCE_NAME \
--machine-type $MACHINE_TYPE \
--zone $ZONE

export MACHINE_TYPE=e2-medium
export REGION=us-west4
export ZONE=us-west4-a
export PORT=8080
export FIREWALL_NAME=allow-tcp-rule-692

# <<< Create an instance template >>>
gcloud compute instance-templates create lb-backend-template \
--region=$REGION \
--network=default \
--subnet=default \
--tags=allow-health-check \
--machine-type=$MACHINE_TYPE \
--image-family=debian-11 \
--image-project=debian-cloud

# <<< Create a managed instance group based on the template >>>
gcloud compute instance-groups managed create lb-backend-group \
--template=lb-backend-template  \
--size=2  \
--zone=$ZONE

# <<< Create a firewall rule named as Firewall rule to allow traffic (80/tcp) >>>
gcloud compute firewall-rules create $FIREWALL_NAME \
--target-tags allow-health-check \
--allow tcp:80

# <<< Create a health check >>>
gcloud compute firewall-rules create fw-allow-health-check \
--network=default \
--action=allow \
--direction=ingress \
--source-ranges=130.211.0.0/22,35.191.0.0/16 \
--target-tags=allow-health-check \
--rules=tcp:80

gcloud compute firewall-rules create www-firewall-network-lb \
--target-tags allow-health-check 
--allow tcp:80

# <<< Create a backend service and add your instance group as the backend to the backend service group with named port (http:80) >>>
gcloud compute backend-services create web-backend-service \
--protocol=HTTP \
--port-name=http \
--health-checks=fw-allow-health-check \
--global

gcloud compute backend-services add-backend web-backend-service \
--instance-group=lb-backend-group \
--instance-group-zone=$ZONE \
--global

# >>> Create a URL map, and target the HTTP proxy to route the incoming requests to the default backend service <<<
gcloud compute url-maps create web-map-http \
--default-service web-backend-service

# >>> Create a target HTTP proxy to route requests to your URL map <<<
gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-map-http

# >>> Create a forwarding rule <<<
gcloud compute addresses create lb-ipv4-1 \
--ip-version=IPV4 \
--global

gcloud compute forwarding-rules create http-content-rule \
--address=lb-ipv4-1\
--global \
--target-http-proxy=http-lb-proxy \
--ports=80