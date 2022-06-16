# SYCL & DPC++

| Optimized for | Description                          |
|:------------- |:------------------------------------ |
| OS            | Tested on Pop_OS! 21.04              |
| Hardware      | Skylake with GEN9 \| Ryzen 1600      |
| Software      | Intel&reg; oneAPI DPC++/C++ Compiler |

## Operating System requirements

All research conducted for CPU and FPGA compilations of all software found here was done on a Ubunutu based Linux Distribution. As of writing there is limited support for FPGA profiling and reports on windows machines, and overall the experience of installing the oneAPI environment, with all support packages and add-ons, as well as developing for DPC++ & SYCL is a far more pleasant experience on Linux.

## DPC++ Environment Setup

To setup the DPC++ development environment, a guide to do so is found here at:

[Download the Intel® oneAPI Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html)

Select the OS of your choice, and follow the instructions to install. For this codebase, the Apt based distro approach was used, where the oneAPI repo was added to APT, and then all packages which was required was installed. The packages installed from this repository are:

intel-basekit

intel-hpckit

intel-iotkit

intel-dlfdkit



all of which will be installed typically in the path /opt/intel/oneapi/

Once all packages are installed, you can now run the DPC++ developer environment. This can be done for user based installations by running.

source /opt/intel/oneapi/setvars.sh

in the bash terminal. 

## Building & Running

To start, make sure the DPC++ Environment setup has been run and all environment variables are active. 

Each code folder for a specific section has a readme which goes through the build and running process. Usually it simply requires running a make file which will handle all compilation using the DPC++ environment

## 
