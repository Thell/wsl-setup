# WSL2 Setup and Notes

## Prerequisites

* Windows 10 Build 19041 or later.
* Enabled WSL2.  
  ([Microsoft WSL documentation][Ref:wsl-docs])
* Docker-Desktop setup with WSL2 backend.  
  ([Docker-Desktop][Ref:Docker-Desktop])
  * sameersbn/apt-cacher-ng:3.3-20200524  
  ([Apt-Cacher-ng][Ref:apt-cacher-ng])
* Installed X server for Windows.  
  ([X410 - X Server for Windows 10][Ref:X410])
* Installed distro from the Microsoft App Store.  
  ([Ubuntu][Ref:UbuntuAppx])
* Installed Visual Studio.  
  ([Visual Studio Community][Ref:VSStudio])
  * UWP Workload
  * C++ Workload
  * Windows 10 SDK
  * Git for Windows
  * Github Extension for Visual Studio
* Cloned [WSL-Launcher repository][Ref:wsl-launcher].

Using [Github Desktop][Ref:GHDesktop] (or similar) is also advantageous.

---------------------------------------

## Notes

__Docker Apt Cacher__: The `apt-cacher-ng` setup between the WSL2 Distro and Docker container isn't the most reliable setup and I'm not positive as to why but I'm thinking it just has to do with 'priming the pump' and getting everything cached in the first place. Once everything is cached it seems to work just fine. The only reason I'm using it is to save on bandwidth while iterating on getting the whole setup in place to go from base WSL2 Distro installs to custom Appx packages for individual projects; so it is definitely _not_ needed.

---------------------------------------

[Ref:apt-cacher-ng]:
https://hub.docker.com/r/sameersbn/apt-cacher-ng
"A caching proxy. Specialized for package files from Linux distributors, primarily for Debian (and Debian based) distributions but not limited to those."

[Ref:Docker-Desktop]:
https://docs.docker.com/docker-for-windows/wsl/
"Docker Desktop WSL 2 backend."

[Ref:GHDesktop]:
https://desktop.github.com/
"Focus on what matters instead of fighting with Git."

[Ref:wsl-docs]:
https://docs.microsoft.com/en-us/windows/wsl/
"Windows Subsystem for Linux Documentation"

[Ref:wsl-launcher]:
https://github.com/microsoft/WSL-DistroLauncher
"Sample/reference launcher app for WSL distro Microsoft Store packages."

[Ref:UbuntuAppx]:
https://wiki.ubuntu.com/WSL
"(without the release version) always follows the recommended release, switching over to the next one when it gets the first point release."

[Ref:VSStudio]:
https://visualstudio.microsoft.com/vs/community/
"Any individual developer can use Visual Studio Community to create their own free or paid apps."

[Ref:X410]:
https://x410.dev/
"X Server for Windows 10"
