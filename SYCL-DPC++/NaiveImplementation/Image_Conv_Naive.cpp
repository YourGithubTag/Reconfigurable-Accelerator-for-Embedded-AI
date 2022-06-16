#include <iostream>
#include <limits>
#include <chrono>
#include <cstdlib>

#include "utils.h"
#include "bmp-utils.h"

using namespace std;

static const char* inputImagePath = "./Images/image01.bmp";
static const int FilterWidth = 6;
static float Filter[36] = {
   64.0f, 64.0f, 64.0f, 64.0f, 64.0f, 64.0f,
   32.0f, 32.0f, 32.0f, 32.0f, 32.0f, 32.0f,
   16.0f, 16.0f, 16.0f, 16.0f, 16.0f, 16.0f,
   8.0f,  8.0f,  8.0f,  8.0f, 8.0f, 8.0f,
   2.0f,  2.0f,  2.0f,  2.0f, 2.0f, 2.0f,
   1.0f,  1.0f,  1.0f,  1.0f, 1.0f, 1.0f};

int main() {

    auto beginNaive = chrono::high_resolution_clock::now();
    float *hInputImage;
    float *hOutputImage;

    int imageRows;
    int imageCols;


    hInputImage = readBmpFloat(inputImagePath, &imageRows, &imageCols);
    printf("imageRows=%d, imageCols=%d\n", imageRows, imageCols);
    printf("filterWidth=%d, \n", FilterWidth);

   int X;
    hOutputImage = (float *)malloc( imageRows*imageCols * sizeof(float) );
    for(X=0; X<imageRows*imageCols; X++)
        hOutputImage[X] = 1234.0;


   int halfFilterWidth = (int)(FilterWidth/2);
   int filterIdx = 0;
   float sum = 0.0f;

   int i; 
   int j;
   int k;
   int l;

   for (i = 0; i < imageRows; i++) 
   {

      for (j = 0; j < imageCols; j++) 
      {

         float sum = 0;
         

         for (k = -halfFilterWidth; k <= halfFilterWidth; k++) 
         {
            for (l = -halfFilterWidth; l <= halfFilterWidth; l++)
            {
               int r = i+k;
               int c = j+l;
               
               r = (r < 0) ? 0 : r;
               c = (c < 0) ? 0 : c;
               r = (r >= imageRows) ? imageRows-1 : r;
               c = (c >= imageCols) ? imageCols-1 : c;       
               
               sum += hInputImage[r*imageCols+c] *
                      Filter[(k+halfFilterWidth)*FilterWidth + 
                         (l+halfFilterWidth)];
            }
         }
         hOutputImage[i*imageCols+j] = sum;
      }
   }
    auto EndNaive = chrono::high_resolution_clock::now();
    std::cout << "TIME" << " \n";
    auto dur = EndNaive - beginNaive;
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();
    std::cout << "\n matrixMult took: " << ms << " milliseconds to run." << std::endl;
    printf("Sequential FInished\n");
    writeBmpFloat(hOutputImage, "output.bmp", imageRows, imageCols,
          inputImagePath);

 }


 
