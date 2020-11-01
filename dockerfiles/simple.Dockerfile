FROM ubuntu

# Update system
RUN apt-get update -qq; apt-get upgrade -yq

RUN apt-get install telnet -y
