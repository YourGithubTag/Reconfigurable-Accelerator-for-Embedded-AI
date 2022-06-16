CXX = dpcpp
CXXFLAGS = -g -std=c++17
INCDIR = Utils
BUFFER_SOURCES = Image_Conv_Naive.cpp Utils/utils.c Utils/bmp-utils.c

NaiveMatrix_EXE = MatrixMult
NaiveMatrix_SRC = Matrix_Mult_Naive.cpp

NaiveImage_EXE = NaiveImageConv
NaiveImage_SRC = Image_Conv_Naive.cpp

all: Naive_Matrix Naive_Conv

Naive_Matrix:
	$(CXX) $(CXXFLAGS) -O0 -o $(NaiveMatrix_EXE) $(NaiveMatrix_SRC)

Naive_Conv:
	$(CXX) $(CXXFLAGS) -O0 -I$(INCDIR) -o $(NaiveImage_EXE) $(BUFFER_SOURCES)

runconv:
	./$(NaiveImage_EXE)

runmatrix:
	./$(NaiveMatrix_EXE)

clean: 
	rm -rf $(NaiveImage_EXE) $(NaiveMatrix_EXE)

