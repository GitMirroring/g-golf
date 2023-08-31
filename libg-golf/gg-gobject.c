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
g_type_from_class (GTypeClass *g_class)
{
  GType type;

  type = G_TYPE_FROM_CLASS(g_class);

  return (type);
}


/*
 * GObject
*/

size_t
g_value_size ()
{
  size_t n = sizeof(GValue);

  return n;
}

GType
g_object_type (GObject *obj)
{
  GType type;

  type = G_OBJECT_TYPE (obj);

  return (type);
}

const gchar*
g_object_type_name (GObject *obj)
{
  const gchar *name;

  name = G_OBJECT_TYPE_NAME (obj);

  return (name);
}

uint
g_object_ref_count (GObject *obj)
{
  return (obj->ref_count);
}

size_t
g_closure_size ()
{
  size_t n = sizeof(GClosure);

  return n;
}

uint
g_closure_ref_count (GClosure *closure)
{
  return (closure->ref_count);
}


/*
 * GParamFlags
 */

GParamFlags
g_param_spec_get_flags (GParamSpec *pspec)
{
    return pspec->flags;
}


/*
 * Parameters and Values
 *   Types and Values
 */

GType
g_type_param_boolean ()
{
  return G_TYPE_PARAM_BOOLEAN;
}

GType
g_type_param_char ()
{
  return G_TYPE_PARAM_CHAR;
}

GType
g_type_param_uchar ()
{
  return G_TYPE_PARAM_UCHAR;
}

GType
g_type_param_int ()
{
  return G_TYPE_PARAM_INT;
}

GType
g_type_param_uint ()
{
  return G_TYPE_PARAM_UINT;
}

GType
g_type_param_long ()
{
  return G_TYPE_PARAM_LONG;
}

GType
g_type_param_ulong ()
{
  return G_TYPE_PARAM_ULONG;
}

GType
g_type_param_int64 ()
{
  return G_TYPE_PARAM_INT64;
}

GType
g_type_param_uint64 ()
{
  return G_TYPE_PARAM_UINT64;
}

GType
g_type_param_float ()
{
  return G_TYPE_PARAM_FLOAT;
}

GType
g_type_param_double ()
{
  return G_TYPE_PARAM_DOUBLE;
}

GType
g_type_param_enum ()
{
  return G_TYPE_PARAM_ENUM;
}

GType
g_type_param_flags ()
{
  return G_TYPE_PARAM_FLAGS;
}

GType
g_type_param_string ()
{
  return G_TYPE_PARAM_STRING;
}
/* G_VALUE_INTERNED_STRING */

GType
g_type_param_param ()
{
  return G_TYPE_PARAM_PARAM;
}

GType
g_type_param_boxed ()
{
  return G_TYPE_PARAM_BOXED;
}

GType
g_type_param_pointer ()
{
  return G_TYPE_PARAM_POINTER;
}

GType
g_type_param_object ()
{
  return G_TYPE_PARAM_OBJECT;
}

GType
g_type_param_unichar ()
{
  return G_TYPE_PARAM_UNICHAR;
}

/* G_TYPE_PARAM_VALUE_ARRAY deprecated in 2.32 */

GType
g_type_param_override ()
{
  return G_TYPE_PARAM_OVERRIDE;
}

GType
g_type_param_gtype ()
{
  return G_TYPE_PARAM_GTYPE;
}

GType
g_type_param_variant ()
{
  return G_TYPE_PARAM_VARIANT;
}
