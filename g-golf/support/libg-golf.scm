;; -*- mode: scheme; coding: utf-8 -*-

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

;;; Commentary:

;;; Code:


(define-module (g-golf support libg-golf)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  
  #:export (;; FFI
            gg_ffi_cif_size
            gg_ffi_type_size
            gg_ffi_prep_cif
            gg_ffi_pack_double

            ;; Misc.
            pointer_address_size

            ;; Constants
            gg_flt_min
            gg_flt_max

            ;; Floats
            float_to_int

            ;; Glib
            g_source_ref_count

            ;; GObject
            g_type_from_class
            g_value_size
            g_object_type
            #;g_object_type_name
            g_object_ref_count
            g_closure_size
            g_closure_ref_count
            g_param_spec_get_flags

            g_type_param_boolean
            g_type_param_char
            g_type_param_uchar
            g_type_param_int
            g_type_param_uint
            g_type_param_long
            g_type_param_ulong
            g_type_param_int64
            g_type_param_uint64
            g_type_param_float
            g_type_param_double
            g_type_param_enum
            g_type_param_flags
            g_type_param_string
            g_type_param_param
            g_type_param_boxed
            g_type_param_pointer
            g_type_param_object
            g_type_param_unichar
            g_type_param_override
            g_type_param_gtype
            g_type_param_variant

            ;; Callback
            g_golf_callback_closure

            ;; Gdk
            ;; gdk_event_get_changed_mask
            ;; gdk_event_get_new_window_state

            ;; Test suite
            test_suite_n_string_ptr
            test_suite_strings_ptr))


;;;
;;; FFI
;;;

(define gg_ffi_cif_size
  (pointer->procedure size_t
                      (dynamic-func "gg_ffi_cif_size"
                                    %libg-golf)
                      (list)))

(define gg_ffi_type_size
  (pointer->procedure size_t
                      (dynamic-func "gg_ffi_type_size"
                                    %libg-golf)
                      (list)))

(define gg_ffi_prep_cif
  (pointer->procedure int
                      (dynamic-func "gg_ffi_prep_cif"
                                    %libg-golf)
                      (list '*			;; *cif
                            unsigned-int	;; n-args
                            '*			;; *return-type
                            '*)))		;; **arg-types

(define gg_ffi_pack_double
  (pointer->procedure double
                      (dynamic-func "gg_ffi_pack_double"
                                    %libg-golf)
                      (list '*)))		;; *ffi-arg


;;;
;;; Misc.
;;;

(define pointer_address_size
  (pointer->procedure size_t
                      (dynamic-func "pointer_address_size"
                                    %libg-golf)
                      (list)))

(define gg_flt_min
  (pointer->procedure float
                      (dynamic-func "gg_flt_min"
                                    %libg-golf)
                      (list)))

(define gg_flt_max
  (pointer->procedure float
                      (dynamic-func "gg_flt_max"
                                    %libg-golf)
                      (list)))



;;;
;;; Floats
;;;

(define float_to_int
  (pointer->procedure int
                      (dynamic-func "float_to_int"
                                    %libg-golf)
                      (list float)))


;;;
;;; Glib
;;;


(define g_source_ref_count
  (pointer->procedure unsigned-int
                      (dynamic-func "g_source_ref_count"
                                    %libg-golf)
                      (list '*)))


;;;
;;; GObject
;;;

(define g_type_from_class
  (pointer->procedure size_t
                      (dynamic-func "g_type_from_class"
                                    %libg-golf)
                      (list '*)))

(define g_value_size
  (pointer->procedure size_t
                      (dynamic-func "g_value_size"
                                    %libg-golf)
                      (list)))

(define g_object_type
  (pointer->procedure size_t
                      (dynamic-func "g_object_type"
                                    %libg-golf)
                      (list '*)))

#!

The following is not working yet, it segfault, complaining that:

  /opt2/bin/guile: symbol lookup error: /opt2/lib/libg-golf.so:
  undefined symbol: g_type_name

  [ which is weird since g_type_name is defined in GObject Type info,
  [ and so it should be part of glib-object.h, afaict at least.

It is not a real problem though, because we already bind g_type_name
using the ffi, in (g-golf gobject type-info).  I'll try to fix this
later.

(define g_object_type_name
  (pointer->procedure '*
                      (dynamic-func "g_object_type_name"
                                    %libg-golf)
                      (list '*)))

!#

(define g_object_ref_count
  (pointer->procedure unsigned-int
                      (dynamic-func "g_object_ref_count"
                                    %libg-golf)
                      (list '*)))

(define g_closure_size
  (pointer->procedure size_t
                      (dynamic-func "g_closure_size"
                                    %libg-golf)
                      (list)))

(define g_closure_ref_count
  (pointer->procedure unsigned-int
                      (dynamic-func "g_closure_ref_count"
                                    %libg-golf)
                      (list '*)))

(define g_param_spec_get_flags
  (pointer->procedure int
                      (dynamic-func "g_param_spec_get_flags"
                                    %libg-golf)
                      (list '*)))

(define g_type_param_boolean
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_boolean"
                                    %libg-golf)
                      (list)))

(define g_type_param_char
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_char"
                                    %libg-golf)
                      (list)))

(define g_type_param_uchar
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_uchar"
                                    %libg-golf)
                      (list)))

(define g_type_param_int
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_int"
                                    %libg-golf)
                      (list)))

(define g_type_param_uint
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_uint"
                                    %libg-golf)
                      (list)))

(define g_type_param_long
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_long"
                                    %libg-golf)
                      (list)))

(define g_type_param_ulong
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_ulong"
                                    %libg-golf)
                      (list)))

(define g_type_param_int64
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_int64"
                                    %libg-golf)
                      (list)))

(define g_type_param_uint64
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_uint64"
                                    %libg-golf)
                      (list)))

(define g_type_param_float
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_float"
                                    %libg-golf)
                      (list)))

(define g_type_param_double
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_double"
                                    %libg-golf)
                      (list)))

(define g_type_param_enum
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_enum"
                                    %libg-golf)
                      (list)))

(define g_type_param_flags
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_flags"
                                    %libg-golf)
                      (list)))

(define g_type_param_string
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_string"
                                    %libg-golf)
                      (list)))

(define g_type_param_param
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_param"
                                    %libg-golf)
                      (list)))

(define g_type_param_boxed
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_boxed"
                                    %libg-golf)
                      (list)))

(define g_type_param_pointer
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_pointer"
                                    %libg-golf)
                      (list)))

(define g_type_param_object
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_object"
                                    %libg-golf)
                      (list)))

(define g_type_param_unichar
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_unichar"
                                    %libg-golf)
                      (list)))

(define g_type_param_override
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_override"
                                    %libg-golf)
                      (list)))

(define g_type_param_gtype
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_gtype"
                                    %libg-golf)
                      (list)))

(define g_type_param_variant
  (pointer->procedure size_t
                      (dynamic-func "g_type_param_variant"
                                    %libg-golf)
                      (list)))


;;;
;;; Callback
;;;


(define g_golf_callback_closure
  (pointer->procedure '*
                      (dynamic-func "g_golf_callback_closure"
                                    %libg-golf)
                      (list '*		;; name
                            '*		;; cb-info
                            '*)))	;; s-proc


;;;
;;; Gdk
;;;

#;(define gdk_event_get_changed_mask
  (pointer->procedure int
                      (dynamic-func "gdk_event_get_changed_mask"
                                    %libg-golf)
                      (list '*)))

#;(define gdk_event_get_new_window_state
  (pointer->procedure int
                      (dynamic-func "gdk_event_get_new_window_state"
                                    %libg-golf)
                      (list '*)))


;;;
;;; Test suite
;;;

(define test_suite_n_string_ptr
  (pointer->procedure '*
                      (dynamic-func "test_suite_n_string_ptr"
                                    %libg-golf)
                      (list)))

(define test_suite_strings_ptr
  (pointer->procedure '*
                      (dynamic-func "test_suite_strings_ptr"
                                    %libg-golf)
                      (list)))
