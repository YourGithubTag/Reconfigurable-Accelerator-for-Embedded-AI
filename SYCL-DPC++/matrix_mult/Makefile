DPCPP_CXX = dpcpp
DPCPP_CXXFLAGS = -std=c++17 -g -o
DPCPP_EXE_NAME = matrix_mult
DPCPP_SOURCES = src/matrix_mult.cpp

all:
	$(DPCPP_CXX) $(DPCPP_CXXFLAGS) $(DPCPP_EXE_NAME) $(DPCPP_SOURCES)

run:
	./$(DPCPP_EXE_NAME)

run_dpcpp:
	./$(DPCPP_EXE_NAME)

clean: 
	rm -rf $(DPCPP_EXE_NAME)



