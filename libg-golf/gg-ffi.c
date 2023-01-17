/*  -*- mode: C; coding: utf-8 -*-

####
#### Copyright (C) 2022
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

*/

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <limits.h>
#include <float.h>
#include <math.h>

#include <ffi.h>
#include <ffitarget.h>


/*
 * FFI
 *
*/

size_t
gg_ffi_cif_size ()
{
  size_t n = sizeof(ffi_cif);

  return n;
}

size_t
gg_ffi_type_size ()
{
  size_t n = sizeof(ffi_type *);

  return n;
}

int
gg_ffi_prep_cif (ffi_cif *cif, \
                 unsigned n_args, \
                 ffi_type *r_type, \
                 ffi_type **a_types)
{
  int ffi_status;

  /* printf("return type: %d\n", r_type->type);
   * for (unsigned i = 0; i < n_args; i++) {
   *   printf ("  arg %d type: %d\n", i, a_types[i]->type);
   * }
  */

  ffi_status = ffi_prep_cif (cif, FFI_DEFAULT_ABI, n_args, r_type, a_types);

  return ffi_status;
}

double
gg_ffi_pack_double (void **arg)
{
  double dble;

  dble =  *(double *) (*arg);
  /* printf ("  ffi_arg dble: %f\n", dble); */

  return dble;
}
