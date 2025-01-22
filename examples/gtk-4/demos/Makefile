####
#### Copyright (C) 2024
#### Free Software Foundation, Inc.

#### This file is part of GNU G-Golf

#### GNU G-Golf is free software; you can redistribute it and/or modify
#### it under the terms of the GNU Lesser General Public License as
#### published by the Free Software Foundation; either version 3 of the
#### License, or (at your option) any later version.

#### GNU G-Golf is distributed in the hope that it will be useful, but
#### WITHOUT ANY WARRANTY; without even the implied warranty of
#### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#### Lesser General Public License for more details.

#### You should have received a copy of the GNU Lesser General Public
#### License along with GNU G-Golf.  If not, see
#### <https://www.gnu.org/licenses/lgpl.html>.
####


CC = gcc

PKGCONFIG = $(shell which pkg-config)

CFLAGS = \
  -fPIC	$(shell $(PKGCONFIG) --cflags glib-2.0 gtk4)

LIBS = \
  -lm $(shell $(PKGCONFIG) --libs glib-2.0 gtk4)

TARGET  = libfpt.so

SOURCES = \
	singular_value_decomposition.c	\
	four_point_transform.c

HEADERS = \
	singular_value_decomposition.h	\
	four_point_transform.h

OBJECTS = $(SOURCES:.c=.o)


all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -shared -o $(TARGET) $(OBJECTS) $(LIBS)
	chmod a-x $@

.DELETE_ON_ERROR:

clean:
	rm -f $(OBJECTS)
	rm -f libfpt.so
