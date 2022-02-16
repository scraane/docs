# Setup Docker in LXC in Proxmox
## When using ZFS

### Step 1 - Install fuse-overlayfs
On the proxmox host install fuse-overlayfs:
apt install fuse-overlayfs

fuse-overlayfs is a similar to overlayfs runs in userspace and can be used without root permissions. Unlike overlayfs, fuse-overlayfs can be also used when the backing filesystem is ZFS, like on Proxmox VE.

### Step 2 - Create a new LXC Container
In Proxmox VE create a unprivileged LXC container with fuse=1,keyctl=1,mknod=1,nesting=1
Start container and login

    cd /usr/local/bin
    wget https://github.com/containers/fuse-overlayfs/releases/download/v1.8.2/fuse-overlayfs-x86_64 -o fuse-overlayfs
    chmod 777 fuse-overlayfs


### Step 3 - Install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh

### Step 4 -Install docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# All done!
