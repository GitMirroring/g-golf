/*  -*- mode: C; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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


#include <limits.h>
#include <float.h>


/*
 * int
*/

int
gg_int_min ()
{
  return INT_MIN;
}

int
gg_int_max ()
{
  return INT_MAX;
}


/*
 * unsigned int
*/

unsigned int
gg_uint_max ()
{
  return UINT_MAX;
}


/*
 * float
*/

float
gg_flt_min ()
{
  return FLT_MIN;
}

float
gg_flt_max ()
{
  return FLT_MAX;
}


/*
 * double
*/

double
gg_dbl_min ()
{
  return DBL_MIN;
}

double
gg_dbl_max ()
{
  return DBL_MAX;
}
