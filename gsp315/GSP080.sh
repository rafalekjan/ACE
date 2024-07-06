# Task 1. Create a function
gcloud config set compute/region us-east4
mkdir gcf_hello_world
cd gcf_hello_world
cat >> index.js<< EOF
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data
    ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";

console.log('My Cloud Function: ${name}');
};
EOF

# Task 2. Create a Cloud Storage bucket
PROJECT_ID=qwiklabs-gcp-01-9475bb71dc6e
gsutil mb -p $PROJECT_ID gs://$PROJECT_ID

# Task 3. Deploy your function
gcloud services disable cloudfunctions.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
gcloud functions deploy helloWorld \
  --stage-bucket $PROJECT_ID \
  --trigger-topic hello_world \
  --runtime nodejs20
gcloud functions describe helloWorld

# Task 4. Test the function
DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'
gcloud functions logs read helloWorld
