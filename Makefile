# General-purpose Makefile for PLINK 1.90
#
# Compilation options:
#   Do not link to LAPACK                    NO_LAPACK

# Leave blank after "=" to disable; put "= 1" to enable
# (when enabled, "#define NOLAPACK" must be uncommented in plink_common.h)
NO_LAPACK =


# should autodetect system
SYS = UNIX
ifdef SystemRoot
  SYS = WIN
else
  UNAME := $(shell uname)
  ifeq ($(UNAME), Darwin)
    SYS = MAC
  endif
endif

CFLAGS=-Wall -O2
BLASFLAGS=-L/usr/lib64/atlas -llapack -lcblas -latlas
LINKFLAGS=-lm -lpthread
ZLIB=zlib-1.2.8/libz.so.1.2.8

ifeq ($(SYS), MAC)
  GCC_GTEQ_43 := $(shell expr `g++ -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/'` \>= 40300)
  ifeq "$(GCC_GTEQ_43)" "1"
    CFLAGS=-Wall -O2 -flax-vector-conversions
  endif
  BLASFLAGS=-framework Accelerate
  LINKFLAGS=
  ZLIB=zlib-1.2.8/libz.1.2.8.dylib
endif

ifeq ($(SYS), WIN)
# Note that, unlike the Linux and Mac build processes, this STATICALLY links
# LAPACK, since we have not gotten around to trying dynamically-linked LAPACK
# on Windows.
# If you don't already have LAPACK built, you'll probably want to turn on
# NO_LAPACK.
  BLASFLAGS=-L. lapack/liblapack.a -L. lapack/librefblas.a
  LINKFLAGS=-lm -static-libgcc
  ZLIB=zlib-1.2.8/libz.a
endif

ifdef NO_LAPACK
  BLASFLAGS=
endif

SRC = plink.c plink_assoc.c plink_calc.c plink_cluster.c plink_cnv.c plink_common.c plink_data.c plink_dosage.c plink_family.c plink_filter.c plink_glm.c plink_help.c plink_homozyg.c plink_lasso.c plink_ld.c plink_matrix.c plink_misc.c plink_set.c plink_stats.c SFMT.c dcdflib.c pigz.c yarn.c

# In the likely event that you are concurrently using PLINK 1.07, we suggest
# either renaming that binary to "plink1" or this one to "plink2".

plink: $(SRC)
	g++ $(CFLAGS) $(SRC) -o plink $(BLASFLAGS) $(LINKFLAGS) -L. $(ZLIB)

plinkw: $(SRC)
	g++ $(CFLAGS) $(SRC) -c
	gfortran -O2 $(OBJ) -o plink -Wl,-Bstatic $(BLASFLAGS) $(LINKFLAGS) -L. $(ZLIB)
