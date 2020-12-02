<p align="center">
  <img width="100" src="https://raw.githubusercontent.com/llbit/chunky-docs/master/images/logo.png" alt="Chunky logo">
</p>
<h1 align="center">jackjt8's Chunky Installer </h1>

<div align="center"> The following script designed to streamline the Chunky installation process on Windows systems by testing for typical issues and addressing them. </div>

---

* Checks if Java is installed - Prompt if missing
* Checks if Java architecture matches OS architecture - Prompt for mis-match
* Checks if JavaFX is present:
		- If using JDK8 it suggests using Zulu (for inbuilt JFX)
		- If using JDK11+ the script will download OpenJFX
* Generates .bat files which can launch ChunkyLauncher
		- ChunkyLauncher.bat also logs to log.txt which is helpful for debugging.

---

TODOs

* Need to pass JDK11+ modules into the ChunkyLauncher if not done automatically so Chunky can actually launch...

* Custom Install directory

* Cleanup/trim unneeded files

* Hybrid HTA UI

