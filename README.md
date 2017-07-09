# Jekyll S2I Docker Image

This repository contains the source for building Jekyll sites as reproducible Docker images using source-to-image. The resulting image can be run using Docker.

It is based on the work here: https://github.com/ComputerScienceHouse/s2i-jekyll.

## Installation

This image is available on DockerHub. To pull it, run:

```
docker pull tobru/s2i-jekyll
```

To build the image from scratch, run:

```
git clone https://github.com/tobru/s2i-jekyll.git
cd s2i-jekyll
make build
```

## Standalone Usage

To build a Jekyll site using standalone S2I and then run the resulting image with Docker, execute:

```
s2i build [path to your app/git clone url] tobru/s2i-jekyll my-jekyll-site
docker run -p 8080:8080 my-jekyll-site
```

## OpenShift Usage

To use this image within your OpenShift cluster, use the included `openshift-jekyll.json` to create the ImageStream within your project. For cluster administrators, you can make this image available to all users by running the following command on a master or logged in as a user with administrative privileges on the `openshift` namespace:

```
oc create -f openshift-jekyll.json -n openshift
```

## Test

This repository includes the S2I test framework, which launches tests to check the functionality of a simple Jekyll site built on top of this image.

```
cd s2i-jekyll
make test
```

