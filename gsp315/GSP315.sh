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
REGION=
gsutil mb -p $PROJECT_ID -l $REGION gs://$PROJECT_ID

# Task 2. Create a Pub/Sub topic
TopicName=
SubscriptionName=
gcloud pubsub topics create $TopicName
# gcloud  pubsub subscriptions create --topic $TopicName $SubscriptionName
# gcloud pubsub topics publish $TopicName --message "Hello"

# Task 3. Create the thumbnail Cloud Function
CloudFunctionName=

mkdir gcf_$CloudFunctionName
cd gcf_$CloudFunctionName
cat >> index.js<< EOF
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('', cloudEvent => {
  const event = cloudEvent.data;
  console.log('Event: ${event}');
  console.log('Hello ${event.bucket}');
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log('Processing Original: gs://${bucketName}/${fileName}');
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
            console.log('Error: ${err}');
            reject(err);
          })
          .on("finish", () => {
            console.log('Success: ${fileName} → ${newFilename}');
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
                  console.log('Message ${messageId} published.');
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log('gs://${bucketName}/${fileName} is not an image I can handle');
    }
  }
  else {
    console.log('gs://${bucketName}/${fileName} already has a thumbnail');
  }
});
EOF

gcloud services disable cloudfunctions.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
gcloud functions deploy $CloudFunctionName \
--gen2
--trigger-bucket gs://$PROJECT_ID \
--entry-point $CloudFunctionName
gcloud functions describe $CloudFunctionName

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

# Task 4. Test the Infrastructure

# Task 5. Remove the previous cloud engineer

