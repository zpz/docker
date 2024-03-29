# Docker

This repo defines a few Docker images that are intended to be used as base images in my Docker work flow.

Some of these images may be pushed to the [repository 'zppz' on Dockerhub](https://hub.docker.com/u/zppz).

My Docker workflow has these main components:

- The image [zppz/tiny](https://github.com/zpz/docker-tiny). This minimalistic image intends to be quite stable. It contains commands to generate image versions based on date or datetime in fixed length and format. It also contains commands to find the latest version of an image that is tagged by such sortable versions.
- The image [zppz/mini](https://github.com/zpz/docker-mini). This image contains shell scripts for building images and running containers. One uses `zppz/tiny` to find the latest version of `zppz/mini` to use. Because user does not need to hard-code the version of `zppz/mini`, this image is updated as often as needed, as long as the user API of its scripts is stable.
- The command [`run-docker`](https://github.com/zpz/docker-mini/blob/master/bin/run-docker). This is the main command for running Docker containers. This command needs to be fairly stable because it's installed on every machine that needs it. This stability is achieved by using `zppz/tiny` to find the latest `zppz/mini` and use utilities therein.
- Finally, the current repo, `docker`, defines a few base images. The main one is a Python image. However, the Docker workflow is not tied to these base images---a repo can use any base image that meets their need.

An example project that uses this workflow is [biglist](https://github.com/zpz/biglist).

A [blog series](https://zpz.github.io/blog/python-docker-stack-1/) describes an early version of this workflow.