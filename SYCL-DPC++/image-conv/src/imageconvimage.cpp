#include <CL/sycl.hpp>
#include <array>
#include <iostream>
#include <chrono>
#include <cstdlib>
#include "dpc_common.hpp"
#if FPGA || FPGA_EMULATOR || FPGA_PROFILE
#include <CL/sycl/INTEL/fpga_extensions.hpp>
#endif

using namespace sycl;
using namespace std;

#include "utils.h"
#include "bmp-utils.h"

static const char* inputImagePath = "./Images/image01.bmp";

static const int FilterWidth = 6;
static float filter[36] = {
   64.0f, 64.0f, 64.0f, 64.0f, 64.0f, 64.0f,
   32.0f, 32.0f, 32.0f, 32.0f, 32.0f, 32.0f,
   16.0f, 16.0f, 16.0f, 16.0f, 16.0f, 16.0f,
   8.0f,  8.0f,  8.0f,  8.0f, 8.0f, 8.0f,
   2.0f,  2.0f,  2.0f,  2.0f, 2.0f, 2.0f,
   1.0f,  1.0f,  1.0f,  1.0f, 1.0f, 1.0f};

int main() {
  // Create device selector for the device of your interest.
#if FPGA_EMULATOR
  // DPC++ extension: FPGA emulator selector on systems without FPGA card.
  INTEL::fpga_emulator_selector d_selector;
#elif FPGA || FPGA_PROFILE
  // DPC++ extension: FPGA selector on systems with FPGA card.
  INTEL::fpga_selector d_selector;
#else
  // The default device selector will select the most performant device.
  default_selector d_selector;
#endif

  float *hInputImage;
  float *hOutputImage;

  int imageRows;
  int imageCols;
  int i;


  hInputImage = readBmpFloat(inputImagePath, &imageRows, &imageCols);
  printf("imageRows=%d, imageCols=%d\n", imageRows, imageCols);

  printf("filterWidth=%d, \n", FilterWidth);


  hOutputImage = (float *)malloc( imageRows*imageCols * sizeof(float) );
  for(i=0; i<imageRows*imageCols; i++)
    hOutputImage[i] = 1234.0;

  const size_t filterWidth = (const size_t)FilterWidth;
  const size_t ImageRows =  (const size_t)imageRows;
  const size_t ImageCols = (const size_t)imageCols;

  try {
    queue q(d_selector, dpc_common::exception_handler);

    cout << "Device: " << q.get_device().get_info<info::device::name>() << "\n";

    std::cout << "Running on device: "
              << q.get_device().get_info<info::device::name>() << "\n";

    auto begin = chrono::high_resolution_clock::now();

    buffer<float, 1> image_in_buf(hInputImage, range<1>(ImageRows*ImageCols));
    buffer<float, 1> image_out_buf(hOutputImage, range<1>(ImageRows*ImageCols));

    range<2> num_items{ImageRows, ImageCols};

    buffer<float, 1> filter_buf(filter, range<1>(filterWidth*filterWidth));

    int halffilterWidth = (int)filterWidth/2;

    q.submit([&](handler &h) {

      accessor srcPtr(image_in_buf, h, read_only);
      auto dstPtr = image_out_buf.get_access<access::mode::write>(h);
      auto f_acc = filter_buf.get_access<access::mode::read>(h);

          h.parallel_for(num_items, [=](id<2> item) 
          { 
            int row = item[0];
            int col = item[1];

            int halfWidth = (int)(filterWidth/2);
            int filterIdx = 0;
            float sum = 0.0f;

            for (int k = -halffilterWidth; k <= halffilterWidth; k++) 
            {
              for (int l = -halffilterWidth; l <= halffilterWidth; l++)
              {
                  int r = row+k;
                  int c = col+l;
                  
                  r = (r < 0) ? 0 : r;
                  c = (c < 0) ? 0 : c;
                  r = (r >= ImageRows) ? ImageRows-1 : r;
                  c = (c >= ImageCols) ? ImageCols-1 : c;       
                  
                  sum += srcPtr[r*ImageCols+c] *
                        f_acc[(k+halffilterWidth)*filterWidth + 
                            (l+halffilterWidth)];
                }
              }
                dstPtr[row*ImageCols+col] = sum;
              }
            );
          });

          q.wait();


        std::cout << "TIME" << " \n";
        auto end = chrono::high_resolution_clock::now();
        auto dur = end - begin;
        auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();
        std::cout << "\n Convolution took: " << ms << " milliseconds to run." << std::endl;

      } catch (sycl::exception const &e) {
        std::cout << "An exception is caught for image convolution.\n";
        std::terminate();
      }

      printf("finished\n");
      writeBmpFloat(hOutputImage, "out2.bmp", imageRows, imageCols,
              inputImagePath);
  return 0;
}
