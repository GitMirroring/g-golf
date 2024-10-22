/*  -*- mode: C; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2023
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation; either version 3 of the
;;;; License, or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.

;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with GNU G-Golf.  If not, see
;;;; <https://www.gnu.org/licenses/lgpl.html>.
;;;;

*/

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <limits.h>
#include <float.h>
#include <math.h>

#include <glib.h>
#include <glib-object.h>


/*
 * Test suite
 *
*/

char**
test_suite_n_string_ptr ()
{
  char** strings = malloc(3 * sizeof(char*));

  for (int i = 0 ; i < 3; ++i)
    strings[i] = malloc(3 * sizeof(char));

  strings[0] = "foo";
  strings[1] = "bar";
  strings[2] = "baz";

  return strings;
}

char**
test_suite_strings_ptr ()
{
  char** strings = malloc(4 * sizeof(char*));

  for (int i = 0 ; i < 3; ++i)
    strings[i] = malloc(3 * sizeof(char));

  strings[0] = "foo";
  strings[1] = "bar";
  strings[2] = "baz";
  strings[3] = NULL;

  return strings;
}
