# ClamAVDocker
Running ClamAV in Docker, whilst setting permissions to run as a non root user for deploying to Kubernetes.

# Special Thanks
Shout out to [mko-x](https://github.com/mko-x/docker-clamav) for providing the majority of the contents for the Dockerfile. The only differences between the Dockerfile in this repo and the one in mko-x's repo is the setting of permissions allowing the container to run as a non-root user in Kubernetes.
