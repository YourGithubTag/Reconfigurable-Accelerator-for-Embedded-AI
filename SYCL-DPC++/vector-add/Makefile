CXX = dpcpp
CXXFLAGS = -O2 -g -std=c++17

VECT_EXE_NAME = vector-add
VECT_SOURCES = src/vector-add.cpp

all: VectorAdd

VectorAdd:
	$(CXX) $(CXXFLAGS) -o $(VECT_EXE_NAME) $(VECT_SOURCES)

run: 
	./$(VECT_EXE_NAME)
clean: 
	rm -f $(VECT_EXE_NAME)
