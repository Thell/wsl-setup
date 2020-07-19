# WSL2 Setup and Notes

## Prerequisites

* Windows 10 Build 19041 or later.
* Enabled WSL2.
  ([Microsoft WSL documentation][Ref:wsl-docs])
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

~~Docker-Desktop setup with WSL2 backend. ([Docker-Desktop][Ref:Docker-Desktop])~~  
~~sameersbn/apt-cacher-ng:3.3-20200524 ([Apt-Cacher-ng][Ref:apt-cacher-ng])~~

~~__Docker Apt Cacher__: The `apt-cacher-ng` setup between the WSL2 Distro and Docker container isn't the most reliable setup and I'm not positive as to why but I'm thinking it just has to do with 'priming the pump' and getting everything cached in the first place. Once everything is cached it seems to work just fine. The only reason I'm using it is to save on bandwidth while iterating on getting the whole setup in place to go from base WSL2 Distro installs to custom appx packages for individual projects; so it is definitely _not_ needed.~~

__Apt-Cacher-NG__  
After being disappointed with the results of using `apt-cacher-ng` between Docker and WSL I decided to try a few alternative setups. An interesting finding was in the network transfer speeds.

Using [iPerf3][Ref:iPerf3]

| From |  To  |   Via    |  Rate    |
|------|------|----------|----------|
|WSL   |WSL   |localhost |  33.8 Gb |
|WSL   |Docker|localhost |   1.4 Gb |
|Docker|WSL   |IP-PrefSrc| 297.0 Mb |
|Docker|Docker|IP-Direct |  32.3 Gb |

Moving the apt-cacher-ng to a WSL Distro _completely_ eliminated the reliability issues and gives notable performance improvements. Using the basic build scripts as a test the time to build from scratch reduced 30% when using the Ubuntu distro and 50% with the Debian distro.

| Build           | Direct | Proxy |
|-----------------|--------|-------|
| Ubuntu (Focal)  |  107s  |  84s  |
| Debian (Buster) |   57s  |  42s  |

The base virtual drive size difference (after an initial update and upgrade) from Ubuntu's `1.8GB` and Debian's `543MB` are worth mentioning when considering a simple service setup like this. It'd be nice to be able to make use of the Ubuntu [minimal images][Ref:UbuntuMinimal] for services like this without having to jump through hoops.

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

[Ref:iPerf3]:
https://iperf.fr/
"iPerf3 is a tool for active measurements of the maximum achievable bandwidth on IP networks."

[Ref:UbuntuMinimal]:
https://ubuntu.com/blog/minimal-ubuntu-released
"The 29MB Docker image for Minimal Ubuntu 18.04 LTS serves as a highly efficient container starting point, and allows developers to deploy multi-cloud containerized applications faster."

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
