# Ready-to-use dev lab for TheHive / Cortex

## Versions :

- TheHive 3.5
- Cortex 3.1
- ElasticSearch 7.8.1


## Requirements :

- Install docker and docker-compose
- curl


## How to use :

- Clone
- Execute command `$ sysctl -w vm.max_map_count=262144` needed for ES
- ./start.sh


## What does start.sh script :
- docker-compose down, up
- initial migration of cortex and thehive databases
- create admin user for cortex and thehive
- create webhook user in thehive
- create API key for webhook user (dump it into ./API file)


## Webhook

./webhook_debug is a test webhook saving all received requests in ./webhook_debug/requests/ directory
