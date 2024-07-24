# Task 4. Create a custom role
nano role-definition.yaml

title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete

gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID \
--file role-definition.yaml

gcloud iam roles create viewer --project $DEVSHELL_PROJECT_ID \
--title "Role Viewer" --description "Custom role description." \
--permissions compute.instances.get,compute.instances.list --stage ALPHA

# Task 6. Update an existing custom role
gcloud iam roles describe editor --project $DEVSHELL_PROJECT_ID
nano new-role-definition.yaml

description: Edit access for App Versions
etag: BwYeA3NPoqs=
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/qwiklabs-gcp-02-0d253843d8fd/roles/editor
stage: ALPHA
title: Role Editor

gcloud iam roles update editor --project $DEVSHELL_PROJECT_ID \
--file new-role-definition.yaml

gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--add-permissions storage.buckets.get,storage.buckets.list

# Task 7. Disable a custom role
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--stage DISABLED

# Task 8. Delete a custom role
gcloud iam roles delete viewer --project $DEVSHELL_PROJECT_ID

# Task 9. Restore a custom role
gcloud iam roles undelete viewer --project $DEVSHELL_PROJECT_ID
