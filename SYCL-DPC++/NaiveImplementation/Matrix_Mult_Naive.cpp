#include <iostream>
#include <limits>
#include <chrono>
#include <cstdlib>


using namespace std;

constexpr int m_size = 300 * 8; 
constexpr int M = m_size / 8;
constexpr int N = m_size / 4;
constexpr int P = m_size / 2;

int main() {

  int i, j, k;
  auto beginNaive = chrono::high_resolution_clock::now();


  float(*a_host)[N] = new float[M][N];
  float(*b_host)[P] = new float[N][P];
  float(*c_host)[P] = new float[M][P];


  for (i = 0; i < M; i++)
    for (j = 0; j < N; j++) a_host[i][j] = 1.0f;


  for (i = 0; i < N; i++)
    for (j = 0; j < P; j++) b_host[i][j] = i + 1.0f;

  for (i = 0; i < M; i++)
    for (j = 0; j < P; j++) c_host[i][j] = 0.0f;

  for (i = 0; i < M; i++) {
    for (k = 0; k < N; k++) {

      for (j = 0; j < P; j++) {
        c_host[i][j] += a_host[i][k] * b_host[k][j];
      }
    }
  }

  auto endNaive = chrono::high_resolution_clock::now();
  delete[] a_host;
  delete[] b_host;
  delete[] c_host;

  std::cout << "TIME" << " \n";
  auto dur = endNaive - beginNaive;
  auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();
  std::cout << "\n matrixMult took: " << ms << " milliseconds to run." << std::endl;

}