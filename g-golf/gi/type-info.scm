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


(define-module (g-golf gi type-info)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (g-golf support enum)
  #:use-module (g-golf init)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf gi common-types)
  #:use-module (g-golf gi base-info)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (g-info-type-to-string
	    g-type-info-is-pointer
	    g-type-info-get-tag
	    g-type-info-get-param-type
	    g-type-info-get-interface
	    g-type-info-get-array-length
	    g-type-info-get-array-fixed-size
	    g-type-info-is-zero-terminated
	    g-type-info-get-array-type))


;;;
;;; Low level API
;;;

#;(define (g-info-type-to-string info-type)
  (let ((pointer (g_info_type_to_string info-type)))
    (if (null-pointer? pointer)
        #f
        (pointer->string pointer))))

(define (g-info-type-to-string info-type)
  (enum->name %gi-info-type info-type))

(define (g-type-info-is-pointer info)
  (gi->scm (g_type_info_is_pointer info) 'boolean))

(define (g-type-info-get-tag info)
  (enum->symbol %gi-type-tag
                (g_type_info_get_tag info)))

(define (g-type-info-get-param-type info n)
  (gi->scm (g_type_info_get_param_type info n) 'pointer))

(define (g-type-info-get-interface info)
  (gi->scm (g_type_info_get_interface info) 'pointer))

(define (g-type-info-get-array-length info)
  (g_type_info_get_array_length info))

(define (g-type-info-get-array-fixed-size info)
  (g_type_info_get_array_fixed_size info))

(define (g-type-info-is-zero-terminated info)
  (gi->scm (g_type_info_is_zero_terminated info) 'boolean))

(define (g-type-info-get-array-type info)
  (and (eq? (g-type-info-get-tag info) 'array)
       (enum->symbol %gi-array-type
                     (g_type_info_get_array_type info))))


;;;
;;; GI Bindings
;;;

#;(define g_info_type_to_string
  (pointer->procedure '*
                      (dynamic-func "g_info_type_to_string"
				    %libgirepository)
                      (list int)))

(define g_type_info_is_pointer
  (pointer->procedure int
                      (dynamic-func "g_type_info_is_pointer"
				    %libgirepository)
                      (list '*)))

(define g_type_info_get_tag
  (pointer->procedure int
                      (dynamic-func "g_type_info_get_tag"
				    %libgirepository)
                      (list '*)))

(define g_type_info_get_param_type
  (pointer->procedure '*
                      (dynamic-func "g_type_info_get_param_type"
				    %libgirepository)
                      (list '* int)))

(define g_type_info_get_interface
  (pointer->procedure '*
                      (dynamic-func "g_type_info_get_interface"
				    %libgirepository)
                      (list '*)))

(define g_type_info_get_array_length
  (pointer->procedure int
                      (dynamic-func "g_type_info_get_array_length"
				    %libgirepository)
                      (list '*)))

(define g_type_info_get_array_fixed_size
  (pointer->procedure int
                      (dynamic-func "g_type_info_get_array_fixed_size"
				    %libgirepository)
                      (list '*)))

(define g_type_info_is_zero_terminated
  (pointer->procedure int
                      (dynamic-func "g_type_info_is_zero_terminated"
				    %libgirepository)
                      (list '*)))

(define g_type_info_get_array_type
  (pointer->procedure int
                      (dynamic-func "g_type_info_get_array_type"
				    %libgirepository)
                      (list '*)))
