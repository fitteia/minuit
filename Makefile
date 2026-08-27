# 0.1.7

ROOT=../OneFit-Engine
CC=gfortran
F90=$(CC) -O3 -fpic -std=legacy -Wno-surprising
PATHLIB=$(ROOT)/lib

all: lib

FSRCS := $(wildcard *.F)

# turn them into object names
OBJS  := $(CSRCS:.c=.o) $(FSRCS:.F=.o)

dd%.o: %.c
	$(CC) $(CCFLAGS) -c $< -o $@

%.o: %.F
	$(F90) -c $< -o $@

lib: $(OBJS) 
#	$(F90) -c *.F
	ar rcs libminuit.a *.o

install: all
	cp libminuit.a  $(PATHLIB)

clean: 
	rm *.o 
	rm *.a
