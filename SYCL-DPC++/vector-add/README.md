# vector-add

| Optimized for | Description                                                                                           |
|:------------- |:----------------------------------------------------------------------------------------------------- |
| OS            | Tested on Pop_OS! 21.04                                                                               |
| Hardware      | Skylake with GEN9 or newer, Intel(R) Programmable Acceleration Card with Intel(R) Arria(R) 10 GX FPGA |
| Software      | Intel&reg; oneAPI DPC++/C++ Compiler                                                                  |

## Building the `vector-add` Program for CPU and GPU

> Note: if you have not already done so, set up your CLI 
> environment by sourcing  the setvars script located in 
> the root of your oneAPI installation. 
> 
> Linux Sudo: . /opt/intel/oneapi/setvars.sh  
> Linux User: . ~/intel/oneapi/setvars.sh  
> 

### On a Linux System

Perform the following steps:

1. Build the program using the following `make` commands (default uses buffers):
   
   ```
   make all
   ```

2. Run the program using:
   
   ```
   make run
   ```

3. Clean the program using:  
   
   ```
   make clean 
   ```

## Building the `vector-add` Program for Intel(R) FPGA

### On a Linux System

Perform the following steps:

1. Clean the `vector-add` program using:
   
   ```
   make clean -f Makefile.fpga
   ```

2. Based on your requirements, you can perform the following:
   
   * Build and run for FPGA emulation using the following commands:
     
     ```
     make fpga_emu -f Makefile.fpga
     make run_emu -f Makefile.fpga
     ```
     
     * Build and run for FPGA hardware.
       **NOTE:** The hardware compilation takes a long time to complete.
       
       ```
       make hw -f Makefile.fpga
       make run_hw -f Makefile.fpga
       ```
     
     * Generate static optimization reports for design analysis. Path to the reports is `vector-add_report.prj/reports/report.html`
       
       ```
       make report -f Makefile.fpga
       ```

## Running the binaries

Using the command line you can run the outputted 

    ./vector-add

or

    ./vector-add.fpga_emu

### Application Parameters

### Example of Output

<pre>
Running on device:        Intel(R) Gen(R) HD Graphics NEO
Vector size: 10000
[0]: 0 + 0 = 0
[1]: 1 + 1 = 2
[2]: 2 + 2 = 4
...
[9999]: 9999 + 9999 = 19998
Vector add successfully completed on device.
</pre>
