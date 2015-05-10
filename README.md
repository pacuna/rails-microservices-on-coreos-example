## Rails microservices example

This repo contains a very simple example of how you can communicate
microservices running inside containers in different nodes inside of a
CoreOS cluster. This can be a good starting point for developing 
distributed rails microservices using docker and CoreOS.

The two services are very simple. Just two models: user and comment.
The idea it's to launch two separate containers in different nodes of a cluster
and allow communication between the services using http calls.

Once you have the project setted up, you'll have a /user/1/comments url, which will
be pointing to one service, but fetching the data from another service.

### Instructions

First you need your own discovery URL in order to manage your CoreOS cluster.
In this example we are going to use 3 nodes, so first get a valid token using:

```
curl https://discovery.etcd.io/new?size=3
```

Put that in the user-data config file replacing the discovery field.

Next, run:

```
vagrant up
```

Vagrant is going to bring three CoreOS nodes already configured to works as a cluster.

Login into the first node using the following commands:
More info about this [here](https://coreos.com/blog/coreos-clustering-with-vagrant/).

```
ssh-add ~/.vagrant.d/insecure_private_key
vagrant ssh core-01 -- -A
```

Now that you are inside of the node 01, go to the share folder (shared with the host) and
you'll see the two services folders (user and comment). In each one of this folders
you're going to find rails applications and systemd services for running the containers inside the cluster.

First, go inside the comment-service folder and run:

```
fleetctl load comment.service
fleetctl load commentsk.service
```

The comment.service service is going to create and run the container with the first
Rails application. The second is just a sidekick for getting information about the
first containers host, since the other microservice has to communicate with it, and we
don't know in which one of the three nodes is going to be deployed. More info about this
[here](https://coreos.com/docs/launching-containers/launching/launching-containers-fleet/).

Now that the services are loaded, you can run:

```
fleetctl start comment.service
fleetctl start commentsk.service
```

Fleetctl is going to run the first microservice somewhere in the cluster. The first time is going 
to take more time, since docker needs to build the rails application container.
You can follow the container log using [journal](https://coreos.com/docs/cluster-management/debugging/reading-the-system-log/):

```
fleetctl journal -f comment.service
```

With journal you can tail the log of the container, no matter in which host is running.

Once it's finished you should see Webrick running in the port 3000 of the container.
The configuration forwards the 3000 port to the 3001 port on the host machine.

In order to see the host in which the service is running, execute:

```
fleetctl list-units
```

list-units is going to show you all the units in the cluster and the ip of the host
in which the container is running.

For example, if list-units gives you something like this:

```
UNIT			MACHINE				ACTIVE	SUB
comment.service		5503faa2.../172.17.8.102	active	running
commentsk.service	5503faa2.../172.17.8.102	active	running
```

it means that the comment service is running in 

```
http://172.17.8.102:3001/comments
```
So if you visit this url, you'll see the results from the first rails application.

Now that we have the first service running, go to the user-service folder and
run the user.service:

```
fleetctl load user.service
fleetctl start user.service
```

Fleetctl again is going to deploy the container in one of the nodes of the cluster. Probably
a different one this time.
Follow the container's log using journal:

```
fleetctl journal -f user.service
```

Once docker finishes, check for the host of the user service:

```
fleetctl list-units

```

```
UNIT			MACHINE				ACTIVE	SUB
comment.service		5503faa2.../172.17.8.102	active	running
commentsk.service	5503faa2.../172.17.8.102	active	running
user.service		84eb6850.../172.17.8.103	active	running
```
In my case, the user service is running in the third node with the address:

```
http://172.17.8.103:3000/users
```

This data is from the user service, but if you visit

```
/users/1/comments
```

You'll see the comments for the first user but fetched from the other service and from
another host probably. All this data is being fetched from sqlite in case you wonder.

### Relevant files

To save you some time, the relevant files are:

[Rails comments service controller](https://github.com/pacuna/rails-microservices-example/blob/master/comment-service/app/controllers/comments_controller.rb)

[Rails user service controller](https://github.com/pacuna/rails-microservices-example/blob/master/user-service/app/controllers/users_controller.rb)

[Rails user service model](https://github.com/pacuna/rails-microservices-example/blob/master/user-service/app/models/user.rb)

[systemd comment service for fleet](https://github.com/pacuna/rails-microservices-example/blob/master/comment-service/comment.service)

[systemd comment service sidekick for fleet](https://github.com/pacuna/rails-microservices-example/blob/master/comment-service/commentsk.service)

[systemd user service for fleet](https://github.com/pacuna/rails-microservices-example/blob/master/user-service/user.service)

### TODO

- Real DB persistence using pgsql
- Cloud deployment
- A lot more

### More info

If you are interested in this project or you have doubts about setting it up, just create
an issue or a pull request.
