CXX = dpcpp
CXXFLAGS = -O2 -g -std=c++17
INCDIR = src/Utils

CONV_EXE_NAME = imageconv
CONV_SOURCES = src/imageconv.cpp src/Utils/utils.c src/Utils/bmp-utils.c

all: build_CONV

build_CONV:
	$(CXX) $(CXXFLAGS) -I$(INCDIR) -o $(CONV_EXE_NAME) $(CONV_SOURCES)

run: 
	./$(CONV_EXE_NAME)

clean: 
	rm -rf $(CONV_EXE_NAME) 
