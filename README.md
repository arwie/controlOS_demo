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
* src - Cache for downloaded packages (no source code here)
