## Rails microservices example

This repo contains a very simple example of how you can communicate
microservices running inside containers in different nodes inside of a
CoreOS cluster.

### Instructions

First you need your own discovery URL in order to manage your CoreOS cluster.
This example is made for 3 nodes, so get a valid token using:

```
curl https://discovery.etcd.io/new?size=3
```

Put that in user-data config.

Next, run:

```
vagrant up
```

Vagrant is going to bring three CoreOS nodes already configured to
works as a cluster.

Login to the first node, but first you have to add your vagrant key to the ssh-agent.
More info about this in [this url](https://coreos.com/blog/coreos-clustering-with-vagrant/).

```
ssh-add ~/.vagrant.d/insecure_private_key
vagrant ssh core-01 -- -A
```

Now that you are inside of first node, go to the shared folder and
you'll se the two services folders. In each one of this folders you're going to find
services for running the containers inside the cluster.

First go inside the comments service and run:

```
fleetctl load comment.service
fleetctl load commentsk.service
```

The comment.service service is going to create and run the container with the first
Rails application. The second one is just a sidekick for get information about the
first containers host, since the other microservice has to communicate with it, and we
don't know in which one of the three nodes is going to be deployed.

Now that the services are loaded, you can run:

```
fleetctl start comment.service
fleetctl start commentsk.service
```

Fleetctl is going to run the microservice somewhere in the cluster. The first time is going 
to take more time, since the containers has to build the rails application image.
You can follow the log, by running:

```
fleetctl journal -f comment.service
```

With journal you can tail the log of the container that's running the image, no matter
the host where its being running of.

Once is finished you should ses webrick running in the port 3001, and since we're
forwarding ports to our local machine, you can go to the ip of the container and visit /comments
in the port 3001. 

In order to see the host in which the service is running execute:

```
fleetctl list-units
```

Now that we have the first service running, go to the users service folder and
run the user.service:

```
fleetctl load user.service
fleetctl start user.service
```

Check the hosts ip of the user service and go the port 3000 in this url /users/1/comments

You'll see the comments for the first user but fetched from the other service and from
other host probably.

