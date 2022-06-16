# matrix_mult

matrixmul is a simple program that multiplies together two large matrices and
verifies the results.  This program is implemented using two ways: 

| Run on:  | Description                                                                  |
|:-------- |:---------------------------------------------------------------------------- |
| OS       | Tested on Pop_OS! 21.04                                                      |
| Hardware | Hardware newer than Ryzen 1600                                               |
| Software | Intel&reg; oneAPI DPC++/C++ Compiler, Intel&reg; oneAPI C++ Compiler Classic |

## Building the `matrrix_mult` Program for DPC++

> Note: if you have not already done so, set up your CLI 
> environment by sourcing  the setvars script located in 
> the root of your oneAPI installation. 
> 
> Linux Sudo: . /opt/intel/oneapi/setvars.sh  
> Linux User: . ~/intel/oneapi/setvars.sh  

## Include Files

The include folder is located at "%ONEAPI_ROOT%\dev-utilities\latest\include" on your development system.

### How to build for DPC++ on Linux

* Build the program using Make   
  make all  

* Run the program  
  make run  

* Clean the program  
  make clean 

## Running the Sample

### Application Parameters

You can modify the computation size by adjusting the size parameter
(must be in multiples of 8) in the  .cpp files. The configurable parameters include:
   size = m_size = 150*8; // Must be a multiple of 8.
   M = m_size / 8;
   N = m_size / 4;
   P = m_size / 2;
