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

Its also worth noting the virtual drive size difference (after an initial update and upgrade).

| Distro          | Size   |
|-----------------|--------|
| Ubuntu (Focal)  |  1.8GB |
| Debian (Buster) |  543MB |

It'd be nice to be able to make use of Ubuntu [minimal images][Ref:UbuntuMinimal] for services like this.

## Nexus Repository

In the past I used the R CRAN binaries provided by the [cran2deb4ubuntu Build Team][Ref:c2d4u] while building RStudio Desktop containers and other fat builds. This allowed me to take advantage of aria2, aft-fast and squid for some fairly major time improvements.

RStudio now hosts a public [RStudio Package Manager][Ref:RSPM] server providing binary package builds that allows the binary installs from within R and R scripts without `sudo apt` that stays up to date with CRAN. Also, since time, as it does, moves forward I wanted to look at some alternatives to a squid setup with SSL termination and focus on something I could _quickly_ and _easily_ tear down and setup that was more dedicated to package management (npm, R, go, docker and so on) and [Sonatype's Nexus Repository OSS][Ref:Nexus] provides just the thing.

The apt-cacher-ng and Nexus repository on a WSL Debian container are lightning fast! So far, the apt-fast and aria2 seem to just be extra setup and run-time overhead. This will likely be true for my other fat builds since the R packages are not being acquired via apt any more and third party binary packages (github releases and such) can use a Nexus raw proxy type.

Its very common for me to rebuild a basic setup with the latest RStudio Preview, Pandoc, MathJax and MathJax 3rd Party Extensions so I tested, downloading all 4 together, 5 times with each time being in a fresh container and averaged.

| Method | Cached | Time    |
|--------|--------|---------|
| wget   | no     | 29.144s |
| aria2c | no     | 26.937s |
| wget   | yes    |  1.523s |
| aria2c | yes    |  1.223s |

Because the Nexus repository is not like a global caching proxy solution the URLs need to be adjusted and since I wont always have the nexus instance running a test is done to see if the proxy is up as well as the normal URL overhead of getting the proper 'latest' URLs.

| Resolve to | Time    |
|------------|---------|
| nexus      |  1.243s |
| remote     |  1.002s |

Seriously... just look at those numbers for the cached downloads and then take out the resolution overhead! **Very nice!**

For something like a Github repo with a 'latest' tagged release the URL is:

From: `https://github.com/jgm/pandoc/releases/latest`  

Resolved Path Suffix:  
`/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-1-amd64.deb`  

Path Prefix:  
Nexus: `http://localhost:8081/repository/github`  
Remote: `https://github.com`  

---------------------------------------

[Ref:apt-cacher-ng]:
https://hub.docker.com/r/sameersbn/apt-cacher-ng
"A caching proxy. Specialized for package files from Linux distributors, primarily for Debian (and Debian based) distributions but not limited to those."

[Ref:c2d4u]:
https://launchpad.net/~c2d4u.team/+archive/ubuntu/c2d4u4.0+
"A PPA for R packages from CRAN's Task Views built against R 4.0 (and subsequent releases). Only building packages for LTS releases."

[Ref:Docker-Desktop]:
https://docs.docker.com/docker-for-windows/wsl/
"Docker Desktop WSL 2 backend."

[Ref:GHDesktop]:
https://desktop.github.com/
"Focus on what matters instead of fighting with Git."

[Ref:iPerf3]:
https://iperf.fr/
"iPerf3 is a tool for active measurements of the maximum achievable bandwidth on IP networks."

[Ref:Nexus]
https://www.sonatype.com/nexus-repository-oss
"The free artifact repository with universal format support."

[Ref:RSPM]:
https://packagemanager.rstudio.com/client/#/
"RStudio Package Manager is a repository management server to organize and centralize R packages across your team, department, or entire organization."

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
