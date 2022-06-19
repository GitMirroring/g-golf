;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2022
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


(define-module (g-golf gi gir-ffi)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  #:use-module (g-golf support enum)
  #:use-module (g-golf gi common-types)
  #:use-module (g-golf gi utils)

  #:export (gi-type-tag-get-ffi-type
            g-type-info-get-ffi-type
            gi-type-info-extract-ffi-return-value
            g-callable-info-prepare-closure))


;;;
;;; Low level API
;;;

(define (gi-type-tag-get-ffi-type type-tag is-pointer?)
  (let ((e-val (enum->value %gi-type-tag type-tag)))
    (if e-val
        (gi->scm (gi_type_tag_get_ffi_type e-val
                                           (scm->gi is-pointer? 'boolean))
                 'pointer)
        (error "Invalid type-tag:" type-tag))))

(define (g-type-info-get-ffi-type info)
  (gi->scm (g_type_info_get_ffi_type info)
           'pointer))

(define (gi-type-info-extract-ffi-return-value type-info
                                               ffi-value
                                               gi-argument)
  (gi_type_info_extract_ffi_return_value type-info
                                         ffi-value
                                         gi-argument))

(define (g-callable-info-prepare-closure info
                                         ffi-cif
                                         ffi-closure-callback
                                         user-data)
  (gi->scm (g_callable_info_prepare_closure info
                                            ffi-cif
                                            ffi-closure-callback
                                            user-data)
           'pointer))


;;;
;;; GI Bindings
;;;

(define gi_type_tag_get_ffi_type
  (pointer->procedure '*		;; *ffi-type
                      (dynamic-func "gi_type_tag_get_ffi_type"
				    %libgirepository)
                      (list int		;; type-tag
                            int)))	;; is-pointer

(define g_type_info_get_ffi_type
  (pointer->procedure '*		;; *ffi-type
                      (dynamic-func "g_type_info_get_ffi_type"
				    %libgirepository)
                      (list '*)))	;; *callback-info

(define gi_type_info_extract_ffi_return_value
  (pointer->procedure void
                      (dynamic-func "gi_type_info_extract_ffi_return_value"
				    %libgirepository)
                      (list '*		;; *type-info
                            '*		;; *ffi-value
                            '*)))	;; *gi-argument

(define g_callable_info_prepare_closure
  (pointer->procedure '*		;; *ffi-closure
                      (dynamic-func "g_callable_info_prepare_closure"
				    %libgirepository)
                      (list '*		;; *callback-info
                            '*		;; *ffi-cif
                            '*		;; *ffi-closure-callback
                            '*)))	;; user-data
