/*  -*- mode: C; coding: utf-8 -*-

####
#### Copyright (C) 2021 - 2023
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

#include <glib.h>
#include <glib-object.h>


/*
 * Type Information
*/

GType
g_type_from_class (GTypeClass *g_class);


/*
 * GObject
*/

size_t
g_value_size ();

GType
g_object_type (GObject *obj);

const gchar*
g_object_type_name (GObject *obj);

uint
g_object_ref_count (GObject *obj);

size_t
g_closure_size ();

uint
g_closure_ref_count (GClosure *closure);


/*
 * GParamFlags
 */

GParamFlags
g_param_spec_get_flags (GParamSpec *pspec);


/*
 * Parameters and Values
 *   Types and Values
 */

GType
g_type_param_boolean ();

GType
g_type_param_char ();

GType
g_type_param_uchar ();

GType
g_type_param_int ();

GType
g_type_param_uint ();

GType
g_type_param_long ();

GType
g_type_param_ulong ();

GType
g_type_param_int64 ();

GType
g_type_param_uint64 ();

GType
g_type_param_float ();

GType
g_type_param_double ();

GType
g_type_param_enum ();

GType
g_type_param_flags ();

GType
g_type_param_string ();
/* G_VALUE_INTERNED_STRING */

GType
g_type_param_param ();

GType
g_type_param_boxed ();

GType
g_type_param_pointer ();

GType
g_type_param_object ();

GType
g_type_param_unichar ();

/* G_TYPE_PARAM_VALUE_ARRAY deprecated in 2.32 */

GType
g_type_param_override ();

GType
g_type_param_gtype ();

GType
g_type_param_variant ();
