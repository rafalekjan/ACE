# Create a bucket for storing the photographs.
# Create a Pub/Sub topic that will be used by a Cloud Function you create.
# Create a Cloud Function.
# Remove the previous cloud engineer’s access from the memories project.

# Create all resources in the REGION region and ZONE zone, unless otherwise directed.
# Use the project VPCs.
# Naming is normally team-resource, e.g. an instance could be named kraken-webserver1
# Allocate cost effective resource sizes. Projects are monitored and excessive resource use will result in the containing project's termination (and possibly yours), so beware. 
# This is the guidance the monitoring team is willing to share; unless directed, use e2-micro for small Linux VMs and e2-medium for Windows or other applications such as Kubernetes nodes.

# Task 1. Create a bucket
PROJECT_ID=$GOOGLE_CLOUD_PROJECT
YOUR_BUCKET_NAME=$GOOGLE_CLOUD_PROJECT-bucket
REGION=us-west1
ZONE=us-west1-a
gsutil mb -p $PROJECT_ID -l $REGION gs://$YOUR_BUCKET_NAME

# Task 2. Create a Pub/Sub topic
TopicName=topic-memories-959
gcloud pubsub topics create $TopicName

# Task 3. Create the thumbnail Cloud Function
CloudFunctionName=memories-thumbnail-generator

mkdir gcf_$CloudFunctionName
cd gcf_$CloudFunctionName
cat > index.js <<'EOF_END'
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('memories-thumbnail-generator', cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${event}`);
  console.log(`Hello ${event.bucket}`);

  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "topic-memories-959";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
});
EOF_END

cat >> package.json<< EOF
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
EOF

sed -i "s/const topicName = \"topic-memories-581\";/const topicName = \"$CloudFunctionName\";/" index.js
sed -i "s/memories-thumbnail-maker/xxx-xxx-xxx/" index.js

gcloud services disable \
  run.googleapis.com \
  eventarc.googleapis.com
gcloud services enable \
  run.googleapis.com \
  eventarc.googleapis.com

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
--role=roles/eventarc.eventReceiver

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com \
--role='roles/pubsub.publisher'

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountTokenCreator

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
--role=roles/pubsub.publisher

gcloud functions deploy $CloudFunctionName \
--gen2 \
--runtime nodejs20 \
--trigger-resource $YOUR_BUCKET_NAME \
--trigger-event google.storage.object.finalize \
--entry-point $CloudFunctionName \
--region=$REGION \
--source . \
--quiet

gcloud run services describe $CloudFunctionName --region $REGION

# Task 4. Test the Infrastructure
curl https://storage.googleapis.com/cloud-training/gsp315/map.jpg --output map.jpg
gsutil cp map.jpg gs://$YOUR_BUCKET_NAME
rm map.jpg

# Task 5. Remove the previous cloud engineer
USERNAME2=student-00-615144ea79f1@qwiklabs.net

gcloud projects remove-iam-policy-binding $PROJECT_ID \
--member=user:$USERNAME2 \
--role=roles/viewer
