controlOS examples project
===

Source code for my videos on YouTube: https://www.youtube.com/@arwie

Git tags correspond to the video release dates.


Directory structure
---

* [codesys](/codesys/) - CODESYS application project and scripts
* [code](/code/) - Links to relevant source code locations
	* [app](/root/projectroot/usr/lib/app/) - Main Python application
	* [shared](/root/local_src/python-shared/shared/) - Shared Python module (code used by app, gui and scripts)
	* [gui](/root/projectroot/usr/lib/gui/) - User interface (HTML, Python)
	* [esp32](/root/local_src/esp32/) -  ESP32 based gadgets (C++)
	* ~~[mc](/root/projectroot/usr/lib/mc/)~~ - Legacy Servotronix SoftMC code (BASIC)
	* ~~[arduino](/root/local_src/arduino/)~~ - Legacy Arduino based gadgets (C++)
* [root](/root/) - PTXdist project for the root partition
	* [projectroot](/root/projectroot/) - Files which are copied to the target
* [boot](/boot/) - PTXdist project for bootloader and system image
* [images](/images/) - Links to the built images.



Building a fully simulated system for VirtualBox
---

For the build you need a Linux system with podman, fuse-overlayfs and virtualbox installed.

First clone this repo and change into the new directory.
Create a build container by running the *ptxdist/create* script.
~~~
[client@gemini wksp]$ git clone git@github.com:arwie/controlOS_demo.git
Cloning into 'controlOS_demo'...
[client@gemini wksp]$ cd controlOS_demo/
[client@gemini controlOS_demo]$ ./ptxdist/create
STEP 1/19: FROM debian:bookworm-slim
...
~~~

All source archives needed to build the target Linux system will be downloaded automatically during the build, except the CODESYS runtime and CodeMeter.
In a Windows CODESYS installation these files are located under *C:\Program Files\CODESYS 3.5.20.50\CODESYS* in the folders *CODESYS Control for Linux SL\Delivery\linux* and *CODESYS CodeMeter for Linux SL\Delivery*.
Copy the necessary *.deb files into the codesys directory of the project.
~~~
[client@gemini controlOS_demo]$ ll codesys/*.deb
-rw-r--r-- 1 client client 25M 14. Mär 12:05 codesys/codemeter-lite_8.20.6539.500_amd64.deb
-rw-r--r-- 1 client client 16M 14. Mär 12:05 codesys/codesyscontrol_linux_4.14.0.0_amd64.deb
~~~

Enter the build container by running the *ptxdist/run* script.
Generate new keys for the project by running *make keygen*.
Now everything is set up for the build: just *make* it.
~~~
[client@gemini controlOS_demo]$ ./ptxdist/run
dev@ptxdist-2025-02-0:~/controlOS_demo$ make keygen
...
dev@ptxdist-2025-02-0:~/controlOS_demo$ make
...
#############################################
Build completed successfully!
dev@ptxdist-2025-02-0:~/controlOS_demo$ exit
~~~

A new VirtualBox VM is created with the *virtualbox/create* script.
Make sure you have configured the host-only network *vboxnet0* without DHCP server.
Now start the controlOS VM either from the virtualbox GUI or with the *virtualbox/start* script.
~~~
[client@gemini controlOS_demo]$ ./virtualbox/create
Virtual machine 'controlOS_demo' is created and registered.
[client@gemini controlOS_demo]$ ./virtualbox/start
VM "..." has been successfully started.
~~~
When the VM is running, you can access the user WEB-UI at *http://90.0.0.1*.

To gain access to the root console use the *keys/connect* script.
~~~
[client@gemini controlOS_demo]$ cd keys/
[client@gemini keys]$ ./connect
root@controlOS:~ uname -a
Linux controlOS 6.6.74-rt48 #1 SMP PREEMPT_RT 2025-02-01T00:00:00+00:00 x86_64 GNU/Linux
~~~

While connected as root, the developer WEB-UI is also available at *http://90.0.0.1:8000*.
There you can view the log, install updates and play with simulated IOs.
