# Task 1. Create a bucket
YOUR_BUCKET_NAME=qwiklabs-gcp-02-705ea5d0748a
gsutil mb gs://$YOUR_BUCKET_NAME

# Task 2. Upload an object into your bucket
curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
gsutil cp ada.jpg gs://$YOUR_BUCKET_NAME
rm ada.jpg

# Task 3. Download an object from your bucket
gsutil cp -r gs://$YOUR_BUCKET_NAME/ada.jpg .

# Task 4. Copy an object to a folder in the bucket
gsutil cp gs://$YOUR_BUCKET_NAME/ada.jpg gs://$YOUR_BUCKET_NAME/image-folder/

# Task 5. List contents of a bucket or folder
gsutil ls gs://$YOUR_BUCKET_NAME

# Task 6. List details for an object
gsutil ls -l gs://$YOUR_BUCKET_NAME/ada.jpg

# Task 7. Make your object publicly accessible
gsutil acl ch -u AllUsers:R gs://$YOUR_BUCKET_NAME/ada.jpg

# Task 8. Remove public access
gsutil acl ch -d AllUsers gs://$YOUR_BUCKET_NAME/ada.jpg

gsutil rm gs://$YOUR_BUCKET_NAME/ada.jpg
