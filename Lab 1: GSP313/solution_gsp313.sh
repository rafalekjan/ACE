# https://raw.githubusercontent.com/quiccklabs/Labs_solutions/master/Implement%20Load%20Balancing%20on%20Compute%20Engine%20Challenge%20Lab/quicklabgsp313.sh

export REGION="${ZONE%-*}"

# stworzenie vpc
gcloud compute networks create nucleus-vpc --subnet-mode=auto

gcloud compute instances create $INSTANCE_NAME \
          --network nucleus-vpc \
          --zone $ZONE  \
          --machine-type e2-micro  \
          --image-family debian-10  \
          --image-project debian-cloud 

#???
gcloud container clusters create nucleus-backend \
--num-nodes 1 \
--network nucleus-vpc \
--zone $ZONE
 
#???
gcloud container clusters get-credentials nucleus-backend \
--zone $ZONE
 
#???
kubectl create deployment hello-server \
--image=gcr.io/google-samples/hello-app:2.0

#???
kubectl expose deployment hello-server \
--type=LoadBalancer \
--port $PORT


cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

 # <<< Create an instance template >>>
gcloud compute instance-templates create web-server-template \
--metadata-from-file startup-script=startup.sh \
--network nucleus-vpc \
--machine-type g1-small \
--region $ZONE
 
#???
gcloud compute target-pools create nginx-pool --region=$REGION
 
# <<< Create a managed instance group based on the template >>>
gcloud compute instance-groups managed create web-server-group \
--base-instance-name web-server \
--size 2 \
--template web-server-template \
--region $REGION
 
# <<< Create a firewall rule named as Firewall rule to allow traffic (80/tcp) >>>
gcloud compute firewall-rules create $FIREWALL_NAME \
--allow tcp:80 \
--network nucleus-vpc
 
# <<< Create a health check >>>
gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed \
set-named-ports web-server-group \
--named-ports http:80 \
--region $REGION
 
# <<< Create a backend service and add your instance group as the backend to the backend service group with named port (http:80) >>>
gcloud compute backend-services create web-server-backend \
--protocol HTTP \
--http-health-checks http-basic-check \
--global
 
 
gcloud compute backend-services add-backend web-server-backend \
--instance-group web-server-group \
--instance-group-region $REGION \
--global
 
# >>> Create a URL map, and target the HTTP proxy to route the incoming requests to the default backend service <<<
gcloud compute url-maps create web-server-map \
--default-service web-server-backend
 
# >>> Create a target HTTP proxy to route requests to your URL map <<<
gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-server-map
 
 
# >>> Create a forwarding rule <<<
gcloud compute forwarding-rules create http-content-rule \
--global \
--target-http-proxy http-lb-proxy \
--ports 80
 
 
gcloud compute forwarding-rules create $FIREWALL_NAME \
--global \
--target-http-proxy http-lb-proxy \
--ports 80
gcloud compute forwarding-rules list