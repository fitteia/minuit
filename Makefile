# 0.1.3

CC=gfortran
F90=$(CC) -O3 -fpic
PATHLIB=../OneFit-Engine/lib

all: lib

FSRCS := $(wildcard *.f)

# turn them into object names
OBJS  := $(CSRCS:.c=.o) $(FSRCS:.f=.o)

dd%.o: %.c
	$(CC) $(CCFLAGS) -c $< -o $@

%.o: %.f
	gfortran -O3 -c $< -o $@



lib: $(OBJS) 
#	$(F90) -c *.F
	ar rcs libminuit.a *.o

install: all
	cp libminuit.a  $(PATHLIB)

clean: 
	rm *.o 
	rm *.a
