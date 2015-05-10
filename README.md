## Rails microservices example

This repo contains a very simple example of how you can communicate
microservices running inside containers in different nodes inside of a
CoreOS cluster.

### Instructions

First you need your own discovery URL in order to manage your CoreOS cluster.
In this example we are going to use 3 nodes, so first get a valid token using:

```
curl https://discovery.etcd.io/new?size=3
```

Put that in user-data config replacing the discovery field.

Next, run:

```
vagrant up
```

Vagrant is going to bring three CoreOS nodes already configured to works as a cluster.

Login to the first node, using the following commands:
More info about this in [this url](https://coreos.com/blog/coreos-clustering-with-vagrant/).

```
ssh-add ~/.vagrant.d/insecure_private_key
vagrant ssh core-01 -- -A
```

Now that you are inside of first node, go to the shared folder and
you'll see the two services folders (user and comment). In each one of this folders
you're going to find systemd services for running the containers inside the cluster.

First, go inside the comments service folder and run:

```
fleetctl load comment.service
fleetctl load commentsk.service
```

The comment.service service is going to create and run the container with the first
Rails application. The second one is just a sidekick for getting information about the
first containers host, since the other microservice has to communicate with it, and we
don't know in which one of the three nodes is going to be deployed.

Now that the services are loaded, you can run:

```
fleetctl start comment.service
fleetctl start commentsk.service
```

Fleetctl is going to run the first microservice somewhere in the cluster. The first time is going 
to take more time, since the containers has to build the rails application image.
You can follow the container log by running:

```
fleetctl journal -f comment.service
```

With journal you can tail the log of the container that's running the image, no matter
in which host is running.

Once it's finished you should see Webrick running in the port 3001, and since we're
forwarding ports to our local machine, you can go to the ip of the container and visit the /comments url
in the port 3001. 

In order to see the host in which the service is running, execute:

```
fleetctl list-units
```
list-units is going to show you all the units in the cluster and the ip of the host
in which the container is running.

Now that we have the first service running, go to the users service folder and
run the user.service:

```
fleetctl load user.service
fleetctl start user.service
```

Once the container finished, check the host of the user service and go the port 3000 
and visit the next url:

```
/users/1/comments
```

You'll see the comments for the first user but fetched from the other service and from
another host probably. All this data is being fetched from mysqlite.

