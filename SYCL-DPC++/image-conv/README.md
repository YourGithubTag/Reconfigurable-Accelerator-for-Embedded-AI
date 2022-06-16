# Image Convolution

Image Convolution computes on the input image pixels and their neighbor pixels using a weighted kernel, which is used as a convolution matrix. 

| Optimized for | Description                                                                                           |
|:------------- |:----------------------------------------------------------------------------------------------------- |
| OS            | Tested on Pop_OS! 21.04                                                                               |
| Hardware      | Skylake with GEN9 or newer, Intel(R) Programmable Acceleration Card with Intel(R) Arria(R) 10 GX FPGA |
| Software      | Intel&reg; oneAPI DPC++ Compiler                                                                      |

### On a Linux System

**The project uses CMake. Perform the following steps to build different targets.** 

```
    mkdir build
    cd build
    cmake ..
    make
```

* make : by default, the emulation executables are built.

## Running the Sample

The executables (for emulation or for FPGA hardware) can be found in the build directory. Use the file name(s) to executable the samples. For example
    ```
    ./image-conv.fpga_emu
    ```
or
    ```
    ./image-conv.fpga
    ```

### Application Parameters
