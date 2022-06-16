#include <CL/sycl.hpp>
#include <iostream>
#include <limits>
#include <chrono>
#include <cstdlib>

#include "dpc_common.hpp"

#include <CL/sycl/INTEL/fpga_extensions.hpp>

using namespace std;
using namespace sycl;

constexpr int m_size = 2400 * 8;
constexpr int M = m_size / 8;
constexpr int N = m_size / 4;
constexpr int P = m_size / 2;

int sequential(float (*c_back)[P]);

int main() {

  // Host memory buffer that device will write data back before destruction.
  float(*c_back)[P] = new float[M][P];

  //INTEL::fpga_emulator_selector d_selector;
  auto d_selector = default_selector{};

  for (int i = 0; i < M; i++)
    for (int j = 0; j < P; j++) c_back[i][j] = 0.0f;

  try {
    queue q(d_selector, dpc_common::exception_handler);

    cout << "Device: " << q.get_device().get_info<info::device::name>() << "\n";

    // Create 2D buffers for matrices, buffer c is bound with host memory c_back

    buffer<float, 2> a_buf(range(M, N));
    buffer<float, 2> b_buf(range(N, P));
    buffer c_buf(reinterpret_cast<float *>(c_back), range(M, P));

    cout << "Problem size: c(" << M << "," << P << ") = a(" << M << "," << N
         << ") * b(" << N << "," << P << ")\n";

    q.submit([&](auto &h) {
      accessor a(a_buf, h, write_only);

      h.parallel_for(range(M, N), [=](auto index) {
        a[index] = 1.0f;
      });
    });

    q.submit([&](auto &h) {
      accessor b(b_buf, h, write_only);
      h.parallel_for(range(N, P), [=](auto index) {
        // Each column of b is the sequence 1,2,...,N
        b[index] = index[0] + 1.0f;
      });
    });
    
    q.wait();

    auto beginpara = chrono::high_resolution_clock::now();

    q.submit([&](auto &h) {

      accessor a(a_buf, h, read_only);
      accessor b(b_buf, h, read_only);
      accessor c(c_buf, h, write_only);

      int width_a = a_buf.get_range()[1];

      h.parallel_for(range(M, P), [=](auto index) {
        int row = index[0];
        int col = index[1];
        float sum = 0.0f;

        for (int i = 0; i < width_a; i++) {
          sum += a[row][i] * b[i][col];
        }
        c[index] = sum;
      });
    });
    q.wait();

    auto Endpara = chrono::high_resolution_clock::now();
    std::cout << "parallel Time:" << " \n";
    auto durparallel = Endpara - beginpara;
    auto msparallel = std::chrono::duration_cast<std::chrono::milliseconds>(durparallel).count();
    std::cout << "\n parallel Matrix took: " << msparallel << " milliseconds to run." << std::endl;
    

  } catch (sycl::exception const &e) {
    cout << "An exception is caught while multiplying matrices.\n";
    terminate();
  }

  int result;
  auto beginSeq = chrono::high_resolution_clock::now();

  result = sequential(c_back);

  auto EndSeq = chrono::high_resolution_clock::now();

  std::cout << "Sequential Time:" << " \n";
  auto durparallel = EndSeq - beginSeq;
  auto msparallel = std::chrono::duration_cast<std::chrono::milliseconds>(durparallel).count();
  std::cout << "\n Sequential Matrix took: " << msparallel << " milliseconds to run." << std::endl;

  delete[] c_back;
  return result;
}

bool ValueSame(float a, float b) {
  return fabs(a - b) < numeric_limits<float>::epsilon();
}

int sequential(float (*c_back)[P]) {
  // Check that the results are correct by comparing with host computing.
  int i, j, k;

  // 2D arrays on host side.
  float(*a_host)[N] = new float[M][N];
  float(*b_host)[P] = new float[N][P];
  float(*c_host)[P] = new float[M][P];

  // Each element of matrix a is 1.int VerifyResult(float (*c_back)[P]);
    for (j = 0; j < P; j++) b_host[i][j] = i + 1.0f;

  // c_host is initialized to zero.
  for (i = 0; i < M; i++)
    for (j = 0; j < P; j++) c_host[i][j] = 0.0f;

  for (i = 0; i < M; i++) {
    for (k = 0; k < N; k++) {
      // Each element of the product is just the sum 1+2+...+n
      for (j = 0; j < P; j++) {
        c_host[i][j] += a_host[i][k] * b_host[k][j];
      }
    }
  }

  bool mismatch_found = false;

  // Compare host side results with the result buffer from device side: print
  // mismatched data 5 times only.
  int print_count = 0;

  for (i = 0; i < M; i++) {
    for (j = 0; j < P; j++) {
      if (!ValueSame(c_back[i][j], c_host[i][j])) {
        cout << "Fail - The result is incorrect for element: [" << i << ", "
             << j << "], expected: " << c_host[i][j]
             << ", but found: " << c_back[i][j] << "\n";
        mismatch_found = true;
        print_count++;
        if (print_count == 5) break;
      }
    }

    if (print_count == 5) break;
  }

  delete[] a_host;
  delete[] b_host;
  delete[] c_host;

  if (!mismatch_found) {
    cout << "Success - The results are correct!\n";
    return 0;
  } else {
    cout << "Fail - The results mismatch!\n";
    return -1;
  }
}
