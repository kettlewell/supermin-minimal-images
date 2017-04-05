# supermin-minimal-images
Create minimal images for docker using supermin

Currently I have this running on CentOS 7, since it's all I really need at this
time, but this concept can be extended to other OS's as well,
and may consider a Fedora image as well at some point

## Instructions
In order to make use of this image, you will need to run this from a machine of
the type of OS you will be creating

ie, if you're building a CentOS 7 image, you need to build it on a CentOS 7 machine

Install supermin:

    `yum install supermin`

then run mkvm-centos7.sh to have your image generated.

I recommend created a separate directory for creating your images first, such as:


    `
    git clone https://github.com/kettlewell/supermin-minimal-images.git
    cd supermin-minimal-images
    ./mkvm-centos7.sh
    `

Currently the image will be automatically imported into your local docker
and the docker container started.
