# Installation guide for Emby under Proxmox 7 within an LXC Container

1. Create an LXC Container (standard approach, well documented in Proxmox)
Use the standard approach within Proxmox and create a privileged Container (incl. definition of hostname, root password)
Select the your target operating system template, e.g. ubuntu 16.04, ubuntu 17.04 or ubuntu 17.10. (you have to download it from the Proxmox server)
Define memory and cpu allocation for your Emby container: e.g. 8 cores, 20GB RAM,… as well as network parameters

2. Install on Intel Graphics acceleration drivers Proxmox Host
First install on the Proxmox host the intel graphics acceleration drivers. (e.g. via Shell JS in the Proxmox manager)
Proxmox host is running Debian stretch.



    apt-get install i965-va-driver

Test if the driver is working. Install vainfo


    apt-get install vainfo

Running vainfo should give you an output comparable to


    error: can’t connect to X server!
    libva info: VA-API version 0.39.4
    libva info: va_getDriverName() returns 0
    libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/i965_drv_video.so
    libva info: Found init function __vaDriverInit_0_39
    libva info: va_openDriver() returns 0
    vainfo: VA-API version: 0.39 (libva 1.7.3)
    vainfo: Driver version: Intel i965 driver for Intel® Kabylake - 1.7.3
    vainfo: Supported profile and entrypoints
    VAProfileMPEG2Simple : VAEntrypointVLD
    VAProfileMPEG2Simple : VAEntrypointEncSlice
    VAProfileMPEG2Main : VAEntrypointVLD
    VAProfileMPEG2Main : VAEntrypointEncSlice
    VAProfileH264ConstrainedBaseline: VAEntrypointVLD
    VAProfileH264ConstrainedBaseline: VAEntrypointEncSlice
    VAProfileH264Main : VAEntrypointVLD
    VAProfileH264Main : VAEntrypointEncSlice
    VAProfileH264High : VAEntrypointVLD
    VAProfileH264High : VAEntrypointEncSlice
    VAProfileH264MultiviewHigh : VAEntrypointVLD
    VAProfileH264MultiviewHigh : VAEntrypointEncSlice
    VAProfileH264StereoHigh : VAEntrypointVLD
    VAProfileH264StereoHigh : VAEntrypointEncSlice
    VAProfileVC1Simple : VAEntrypointVLD
    VAProfileVC1Main : VAEntrypointVLD
    VAProfileVC1Advanced : VAEntrypointVLD
    VAProfileNone : VAEntrypointVideoProc
    VAProfileJPEGBaseline : VAEntrypointVLD
    VAProfileJPEGBaseline : VAEntrypointEncPicture
    VAProfileVP8Version0_3 : VAEntrypointVLD
    VAProfileVP8Version0_3 : VAEntrypointEncSlice
    VAProfileHEVCMain : VAEntrypointVLD
    VAProfileHEVCMain : VAEntrypointEncSlice
    VAProfileHEVCMain10 : VAEntrypointVLD
    VAProfileHEVCMain10 : VAEntrypointEncSlice
    VAProfileVP9Profile0 : VAEntrypointVLD
    VAProfileVP9Profile0 : VAEntrypointEncSlice
    VAProfileVP9Profile2 : VAEntrypointVLD

Well done your host is supporting the appropriate acceleration.

3. GPU passthrough configuration to Emby Container
Find out the right parameter of your graphics card


    ls -l /dev/dri

This should give you a comparable output to the following

    crw-rw---- 1 root video 226,   0 Dec 29 14:06 card0
    crw-rw---- 1 root video 226, 128 Dec 29 14:06 renderD128

Note the numbers behind video:
card0 has the id 226, 0
renderD128 has the id 226,128

Define the gpu passthrough by adding the following lines at the end of your 100.conf file (use the appropriate number 100, 101,… that you assigned before to the Plex container). Please adjust the following lines with the id numbers for your graphics system you have noted down just before. In the last line replace the 100 with the Plex container id of your system.



    nano /etc/pve/lxc/100.conf

-

    lxc.cgroup2.devices.allow = c 226:0 rwm
    lxc.cgroup2.devices.allow = c 226:128 rwm
    lxc.cgroup2.devices.allow = c 29:0 rwm
    lxc.autodev: 1
    lxc.hook.autodev:/var/lib/lxc/100/mount_hook.sh
	
When the container starts, the last line calls a shell script that you need to create to mount the devices appropriately…
Let’s create it:


    nano /var/lib/lxc/100/mount_hook.sh

Add the following lines and adjust the id’s to your graphics system:


    mkdir -p ${LXC_ROOTFS_MOUNT}/dev/dri
    mknod -m 666 ${LXC_ROOTFS_MOUNT}/dev/dri/card0 c 226 0
    mknod -m 666 ${LXC_ROOTFS_MOUNT}/dev/dri/renderD128 c 226 128
    mknod -m 666 ${LXC_ROOTFS_MOUNT}/dev/fb0 c 29 0

Save the file and make it executable.


    chmod 755 /var/lib/lxc/100/mount_hook.sh
    
Your Emby LXC container is ready to boot up incl. GPU passthrough. Well done!

4. Boot-up your container and install Plex media server
Via Console JS of your container execute the following steps

Login with root and the assigned password in step 1
Make sure your system is up-to-date


    apt-get update && sudo apt-get upgrade

Head to the Plex Downloads page and download the current version of Emby Server

Use dpkg to install the Embyserver:


    dpkg -i emby-server*.deb

The rest is than standard Embyconfiguration and media file management which is well documented. So I will not repeat it.
Last step to make sure your Emby server is using hardware acceleration.