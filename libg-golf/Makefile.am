
####
#### Copyright (C) 2016 - 2023
#### Free Software Foundation, Inc.

#### This file is part of GNU G-Golf.

#### GNU G-Golf is free software; you can redistribute it and/or
#### modify it under the terms of the GNU General Public License as
#### published by the Free Software Foundation; either version 3 of
#### the License, or (at your option) any later version.

#### GNU G-Golf is distributed in the hope that it will be useful, but
#### WITHOUT ANY WARRANTY; without even the implied warranty of
#### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#### General Public License for more details.

#### You should have received a copy of the GNU General Public License
#### along with GNU G-Golf.  If not, see
#### <https://www.gnu.org/licenses/gpl.html>.
####


#include $(top_srcdir)/am/guile.mk

lib_LTLIBRARIES = \
	libg-golf.la

libg_golf_la_sources = \
	gg-const.c	\
	gg-ffi.c	\
	gg-utils.c	\
	gg-glib.c	\
	gg-gobject.c	\
	gg-callback.c	\
	gg-test-suite.c	\
	g-golf.c

libg_golf_la_headers = \
	gg-const.h	\
	gg-ffi.h	\
	gg-utils.h	\
	gg-glib.h	\
	gg-gobject.h	\
	gg-callback.h	\
	gg-test-suite.h

libg_golf_la_SOURCES = \
  $(libg_golf_la_headers)	\
  $(libg_golf_la_sources)

libg_golf_la_CFLAGS = \
  $(AM_CFLAGS) \
  $(GUILE_CFLAGS) \
  $(GLIB_CFLAGS) \
  $(GOBJECT_CFLAGS) \
  $(GOBJECT_INTROSPECTION_CFLAGS) \
  $(FFI_CFLAGS)

libg_golf_la_LIBADD = \
  $(GUILE_LIBS) \
  $(GLIB_LIBS) \
  $(GOBJECT_LIBS) \
  $(GOBJECT_INTROSPECTION_LIBS) \
  $(FFI_LIBS)

libg_golf_la_LDFLAGS = \
  -no-undefined \
  $(GUILE_LDFLAGS)

printenv:
	printf '$(libg_golf_la_CFLAGS)\n' \
	printf '$(libg_golf_la_LIBADD)\n'   \
	printf '$(libg_golf_la_LDFLAGS)\n'

# Makefile.am ends here
