#Task 6. New queries in Cloud SQL
export PROJECT_ID=$(gcloud config get-value project)
gcloud config set project $PROJECT_ID

gcloud auth login --no-launch-browser

gcloud sql connect my-demo --user=root --quiet

CREATE DATABASE bike;
