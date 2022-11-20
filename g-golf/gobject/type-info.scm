;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2022
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


(define-module (g-golf gobject type-info)
  #:use-module (rnrs bytevectors)
  #:use-module (ice-9 match)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (rnrs arithmetic bitwise)
  #:use-module (g-golf init)
  #:use-module (g-golf support flags)
  #:use-module (g-golf glib mem-alloc)
  #:use-module (g-golf gi cache-gi)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf support enum)
  #:use-module (g-golf support flags)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (g-type->symbol
            symbol->g-type

            g-type-name
            g-type-from-name
            g-type-parent
            g-type-is-a
            g-type-class-ref
            g-type-class-peek
            g-type-class-unref
            g-type-interface-peek
            g-type-interfaces
            g-type-query
            g-type-register-static-simple
            g-iface-info-struct-new
            g-type-add-interface-static
            g-type-fundamental
            g-type-ensure

            %iface-init-func
            %iface-finalize-func

	    %g-type-fundamental-flags
            %g-type-fundamental-types))


;;;
;;; G-Golf Low level API
;;;

(define %g-type-fundamental-shift 2)

(define (g-type->symbol g-type)
  ;; note that sbank special treat the 'boxed g-type maybe I'll have to
  ;; do it to, let's see how thngs goes, but keep this in mind ...
  (enum->symbol %g-type-fundamental-types
                (bitwise-arithmetic-shift-right (g-type-fundamental g-type)
                                                %g-type-fundamental-shift)))

(define (symbol->g-type symbol)
  (let ((value (enum->value %g-type-fundamental-types
                            (case symbol
                              ((utf8) 'string)
                              ((int32) 'int)
                              ((uint32) 'uint)
                              (else symbol)))))
    (and value
         (bitwise-arithmetic-shift value
                                   %g-type-fundamental-shift))))


;;;
;;; GObject Low level API
;;;

(define (g-type-from-name name)
  (let ((result (g_type_from_name (string->pointer name))))
    (if (= result 0)
        #f
        result)))

(define (g-type-name g-type)
  (gi->scm (g_type_name g-type) 'string))

(define (g-type-parent g-type)
  (g_type_parent g-type))

(define (g-type-is-a g-type is-a-g-type)
  (gi->scm (g_type_is_a g-type is-a-g-type)
           'boolean))

(define (g-type-class-ref g-type)
  (gi->scm (g_type_class_ref g-type) 'pointer))

(define (g-type-class-peek g-type)
  (gi->scm (g_type_class_peek g-type) 'pointer))

(define (g-type-class-unref g-class)
  (g_type_class_unref g-class))

(define (g-type-interface-peek g-class iface-type)
  (gi->scm (g_type_interface_peek g-class iface-type)
           'pointer))

(define (g-type-interfaces g-type)
  (let* ((s-uint (sizeof unsigned-int))
         (s-ulong (sizeof unsigned-long))
         (n-iface-bv (make-bytevector s-uint 0))
         (ifaces (g_type_interfaces g-type
                                    (bytevector->pointer n-iface-bv)))
         (n-iface (u32vector-ref n-iface-bv 0))
         (results (u64vector->list
                   (pointer->bytevector ifaces
                                        (* n-iface s-ulong) 0))))
    (g-free ifaces)
    results))

(define %g-type-query-struct
  (list unsigned-long	;; g-type
        '*		;; type-name
        unsigned-int	;; class-size
        unsigned-int))	;; instance-size

(define (g-type-query-new)
  (make-c-struct %g-type-query-struct
                 (list 0
                       %null-pointer
                       0
                       0)))

(define (g-type-query g-type)
  (let ((type-query (g-type-query-new)))
    (g_type_query g-type type-query)
    (match (parse-c-struct type-query
                           %g-type-query-struct)
      ((g-type type-name class-size instance-size)
       (list g-type
             (gi->scm type-name 'string)
             class-size
             instance-size)))))

(define %class-init-func
  (procedure->pointer void
                      (lambda (g-class class-data)
                        (values))
                      (list '* '*)))

(define %instance-init-func
  (procedure->pointer void
                      (lambda (instance g-class)
                        (values))
                      (list '* '*)))

(define (g-type-register-static-simple parent-type
                                       type-name
                                       class-size
                                       class-init-func
                                       instance-size
                                       instance-init-func
                                       flags)
  (let ((type-flags (gi-cache-ref 'flags 'g-object-type-flags)))
    (g_type_register_static_simple parent-type
                                   (scm->gi type-name 'string)
                                   class-size
                                   (or class-init-func %class-init-func)
                                   instance-size
                                   (or instance-init-func %instance-init-func)
                                   (flags->integer type-flags flags))))

(define %iface-info-struct
  ;; https://docs.gtk.org/gobject/struct.InterfaceInfo.html
  (list '*		;; iface-init-func
        '*		;; iface-finalize-func
        '*))		;; iface-data

(define %iface-init-func
  (procedure->pointer void
                      (lambda (g-iface iface-data)
                        (values))
                      (list '* '*)))

(define %iface-finalize-func
  (procedure->pointer void
                      (lambda (g-iface iface-data)
                        (values))
                      (list '* '*)))

(define* (g-iface-info-struct-new #:key
                                  (iface-init-func %iface-init-func)
                                  (iface-finalize-func %iface-finalize-func)
                                  (iface-data #f))
  (make-c-struct %iface-info-struct
                 (list iface-init-func
                       iface-finalize-func
                       (scm->gi iface-data 'pointer))))

(define (g-type-add-interface-static g-type iface-type iface-info)
  (g_type_add_interface_static g-type
                               iface-type
                               (or iface-info
                                   (g-iface-info-struct-new
                                    #:iface-init-func %iface-init-func
                                    #:iface-finalize-func %iface-finalize-func
                                    #:iface-data #f))))

(define (g-type-fundamental g-type)
  (g_type_fundamental g-type))

(define (g-type-ensure g-type)
  (g_type_ensure g-type))


;;;
;;; GObject Bindings
;;;

(define g_type_name
  (pointer->procedure '*
                      (dynamic-func "g_type_name"
				    %libgobject)
                      (list unsigned-long)))

(define g_type_from_name
  (pointer->procedure unsigned-long
                      (dynamic-func "g_type_from_name"
				    %libgobject)
                      (list '*)))

(define g_type_parent
  (pointer->procedure unsigned-long
                      (dynamic-func "g_type_parent"
				    %libgobject)
                      (list unsigned-long)))

(define g_type_is_a
  (pointer->procedure int
                      (dynamic-func "g_type_is_a"
				    %libgobject)
                      (list unsigned-long
                            unsigned-long)))

(define g_type_class_ref
  (pointer->procedure '*
                      (dynamic-func "g_type_class_ref"
				    %libgobject)
                      (list unsigned-long)))

(define g_type_class_peek
  (pointer->procedure '*
                      (dynamic-func "g_type_class_peek"
				    %libgobject)
                      (list unsigned-long)))

(define g_type_class_unref
  (pointer->procedure void
                      (dynamic-func "g_type_class_unref"
				    %libgobject)
                      (list '*)))

(define g_type_interface_peek
  (pointer->procedure '*
                      (dynamic-func "g_type_interface_peek"
				    %libgobject)
                      (list '*			;; g-class
                            unsigned-long)))	;; iface-type

(define g_type_interfaces
  (pointer->procedure '*
                      (dynamic-func "g_type_interfaces"
				    %libgobject)
                      (list unsigned-long	;; g-type
                            '*)))		;; n-iface (pointer to guint)

(define g_type_query
  (pointer->procedure void
                      (dynamic-func "g_type_query"
				    %libgobject)
                      (list unsigned-long
                            '*)))

(define g_type_register_static_simple
  (pointer->procedure unsigned-long
                      (dynamic-func "g_type_register_static_simple"
				    %libgobject)
                      (list unsigned-long	;; parent-type
                            '*			;; type-name
                            unsigned-int	;; class-size
                            '*			;; class-init (func)
                            unsigned-int	;; instance-size
                            '*			;; instance-init (func)
                            int)))		;; flags

(define g_type_add_interface_static
  (pointer->procedure void
                      (dynamic-func "g_type_add_interface_static"
				    %libgobject)
                      (list unsigned-long	;; g-type
                            unsigned-long	;; iface-type
                            '*)))		;; iface-info

(define g_type_fundamental
  (pointer->procedure size_t
                      (dynamic-func "g_type_fundamental"
				    %libgobject)
                      (list unsigned-long)))

(define g_type_ensure
  (pointer->procedure void
                      (dynamic-func "g_type_ensure"
				    %libgobject)
                      (list unsigned-long)))


;;;
;;; Types and Values
;;;

(define %g-type-fundamental-flags
  (make <gi-flags>
    #:g-name "GTypeFundamentalFlags"
    #:enum-set '((classed . 1)
                 (instantiable . 2)
                 (derivable . 4)
                 (deep-derivable . 8))))

(define %g-type-fundamental-types
  ;; manually built, from the list of fundamental types starting with
  ;; G_TYPE_INVALID -> G_TYPE_OBJECT
  (make <gi-enum>
    #:g-name "GTypeFundamentalTypes"
    #:enum-set '(invalid
                 none
                 interface
                 char
                 uchar
                 boolean
                 int
                 uint
                 long
                 ulong
                 int64
                 uint64
                 enum
                 flags
                 float
                 double
                 string
                 pointer
                 boxed
                 param
                 object
                 variant)))
