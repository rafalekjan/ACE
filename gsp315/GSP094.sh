# Task 1. Create a virtual environment
sudo apt-get install -y virtualenv
python3 -m venv venv
source venv/bin/activate

# Task 2. Install the client library
pip install --upgrade google-cloud-pubsub
git clone https://github.com/googleapis/python-pubsub.git
cd python-pubsub/samples/snippets

# Task 3. Pub/Sub - the Basics
# Task 4. Create a topic
echo $GOOGLE_CLOUD_PROJECT
cat publisher.py
python publisher.py -h
python publisher.py $GOOGLE_CLOUD_PROJECT create MyTopic
python publisher.py $GOOGLE_CLOUD_PROJECT list

# Task 5. Create a subscription
python subscriber.py $GOOGLE_CLOUD_PROJECT create MyTopic MySub
python subscriber.py $GOOGLE_CLOUD_PROJECT list-in-project
python subscriber.py -h

# Task 6. Publish messages
gcloud pubsub topics publish MyTopic --message "Hello"
gcloud pubsub topics publish MyTopic --message "Publisher's name is <YOUR NAME>"
gcloud pubsub topics publish MyTopic --message "Publisher likes to eat <FOOD>"
gcloud pubsub topics publish MyTopic --message "Publisher thinks Pub/Sub is awesome"

# Task 7. View messages
python subscriber.py $GOOGLE_CLOUD_PROJECT receive MySub
