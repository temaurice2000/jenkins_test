#dockerize postgresql on an ubuntu server
FROM ubuntu:20.04

ENV POSTGRESS_DB_USERNAME = postgres
ENV POSTGRESS_DB_PWD = password

# Updating the packages
 RUN apt-get update
 
# Expose the port number for the PostgreSQL database
 EXPOSE 5432
