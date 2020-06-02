# SSTIC-streaming

This repo is an extract of the playbooks from the SSTIC at https://gitlab.com/sstic/streaming-infra/ to build a docker image instead.

The docker container listens on port 8080 for the HTTP part and on port 1935 for the RTMP part. It is up to the final user to add IP filtering, SSL, ...

To directly run the docker from dockerhub simply use :
```
$  docker run --rm --name sstic-streaming -p 80:8080 kimen/sstic-streaming:latest
```
And use your browser to go to port 80 on your localhost.
