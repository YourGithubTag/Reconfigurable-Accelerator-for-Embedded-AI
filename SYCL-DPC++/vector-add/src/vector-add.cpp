#include <CL/sycl.hpp>
#include <vector>
#include <iostream>
#if FPGA || FPGA_EMULATOR
#include <CL/sycl/INTEL/fpga_extensions.hpp>
#endif

using namespace sycl;

// Vector type and data size for this example.
size_t vector_size = 10000;
typedef std::vector<int> IntVector; 

// Create an exception handler for asynchronous SYCL exceptions
static auto exception_handler = [](sycl::exception_list e_list) {
  for (std::exception_ptr const &e : e_list) {
    try {
      std::rethrow_exception(e);
    }
    catch (std::exception const &e) {
#if _DEBUG
      std::cout << "Failure" << std::endl;
#endif
      std::terminate();
    }
  }
};

void InitializeVector(IntVector &a) {
  for (size_t i = 0; i < a.size(); i++) a.at(i) = i;
}

int main(int argc, char* argv[]) {
  // Create device selector for the device of your interest.
#if FPGA_EMULATOR
  // DPC++ extension: FPGA emulator selector on systems without FPGA card.
  INTEL::fpga_emulator_selector d_selector;
#elif FPGA
  // DPC++ extension: FPGA selector on systems with FPGA card.
  INTEL::fpga_selector d_selector;
#else
  // The default device selector will select the most performant device.
  default_selector d_selector;
#endif

  IntVector a, b, sum_sequential, sum_parallel;
  a.resize(vector_size);
  b.resize(vector_size);
  sum_sequential.resize(vector_size);
  sum_parallel.resize(vector_size);
  InitializeVector(a);
  InitializeVector(b);

  try {
    queue q(d_selector, exception_handler);

    std::cout << "Running on device: " << q.get_device().get_info<info::device::name>() << "\n";
    
    std::cout << "Vector size: " << a.size() << "\n";

    range<1> num_items{a.size()};
    buffer a_buf(a);
    buffer b_buf(b);
    buffer sum_buf(sum_parallel.data(), num_items);

    q.submit([&](handler &h) {

      accessor a(a_buf, h, read_only);
      accessor b(b_buf, h, read_only);

      accessor sum(sum_buf, h, write_only, noinit);

      h.parallel_for(num_items, [=](auto i) 
      { 
        sum[i] = a[i] + b[i]; 
      });
    });

  } catch (exception const &e) {
    std::cout << "An exception is caught for vector add.\n";
    std::terminate();
  }

  for (size_t i = 0; i < sum_sequential.size(); i++)
    sum_sequential.at(i) = a.at(i) + b.at(i);

  int indices[]{0, 1, 2, (static_cast<int>(a.size()) - 1)};
  constexpr size_t indices_size = sizeof(indices) / sizeof(int);

  for (int i = 0; i < indices_size; i++) {
    int j = indices[i];
    if (i == indices_size - 1) std::cout << "...\n";
    std::cout << "[" << j << "]: " << a[j] << " + " << b[j] << " = "
              << sum_parallel[j] << "\n";
  }

  a.clear();
  b.clear();
  sum_sequential.clear();
  sum_parallel.clear();

  std::cout << "Vector add successfully completed on device.\n";
  return 0;
}
