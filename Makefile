# location of R library
r_libdir1x = ${R_HOME}/bin
r_libdir2x = ${R_HOME}/lib
# location of R includes
r_includespec = ${R_HOME}/include

ifeq ($(PORTNAME), darwin)
DYSUFFIX = dylib
endif

# we can only build PL/R if libR is available
# Since there is no official way to determine this,
# we see if there is a file that is named like a shared library.
ifneq ($(PORTNAME), darwin)
ifneq (,$(wildcard $(r_libdir1x)/libR*$(DLSUFFIX)*)$(wildcard $(r_libdir2x)/libR*$(DLSUFFIX)*))
	shared_libr = yes;
endif
else
ifneq (,$(wildcard $(r_libdir1x)/libR*$(DYSUFFIX)*)$(wildcard $(r_libdir2x)/libR*$(DYSUFFIX)*))
	shared_libr = yes
endif
endif

# If we don't have a shared library and the platform doesn't allow it
# to work without, we have to skip it.
ifneq (,$(findstring yes, $(shared_libr)$(allow_nonpic_in_shlib)))

MODULE_big	:= plr
PG_CPPFLAGS	+= -I$(r_includespec)
SRCS		+= plr.c pg_conversion.c pg_backend_support.c pg_userfuncs.c pg_rsupport.c
OBJS		:= $(SRCS:.c=.o)
SHLIB_LINK	+= -L$(r_libdir1x) -L$(r_libdir2x) -lR

DATA_built	:= plr.sql 
DOCS		:= README.plr
REGRESS		:= plr
EXTRA_CLEAN	:= doc/HTML.index

ifdef USE_PGXS
PGXS := $(shell pg_config --pgxs)
include $(PGXS)
else
subdir = contrib/plr
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

override CPPFLAGS := -I$(srcdir) -I$(r_includespec) $(CPPFLAGS)
override CPPFLAGS += -DPKGLIBDIR=\"$(pkglibdir)\" -DDLSUFFIX=\"$(DLSUFFIX)\"

else # can't build

all:
	@echo ""; \
	 echo "*** Cannot build PL/R because libR is not a shared library." ; \
	 echo "*** You might have to rebuild your R installation.  Refer to"; \
	 echo "*** the documentation for details."; \
	 echo ""

endif # can't build
