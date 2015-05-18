FROM phusion/passenger-ruby22:0.9.15

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -f /etc/service/nginx/down

# Copy the nginx template for configuration and preserve environment variables
RUN rm /etc/nginx/sites-enabled/default
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf

# create the projects folder and set the workdir
RUN mkdir /home/app/webapp
WORKDIR /home/app/webapp

# copy the project to the containers folder and install gems

COPY Gemfile /home/app/webapp/
COPY Gemfile.lock /home/app/webapp/
RUN bundle install
COPY . /home/app/webapp

# set permissions for the passenger user for this app
RUN chown -R app:app /home/app/webapp

# expose the port
EXPOSE 80
