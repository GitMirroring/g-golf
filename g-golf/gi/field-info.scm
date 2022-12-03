;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2022
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


(define-module (g-golf gi field-info)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (g-golf support utils)
  #:use-module (g-golf support enum)
  #:use-module (g-golf support flags)
  #:use-module (g-golf init)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf gi cache-gi)
  #:use-module (g-golf gi base-info)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (g-field-info-get-flags
            g-field-info-get-offset
            g-field-info-get-type))


;;;
;;; Low level API
;;;

(define (g-field-info-get-flags info)
  (let ((field-info-flags (gi-cache-ref 'flags 'gi-field-info-flags)))
    (integer->flags field-info-flags
                    (g_field_info_get_flags info))))

(define (g-field-info-get-offset info)
  (g_field_info_get_offset info))

(define (g-field-info-get-type info)
  (gi->scm (g_field_info_get_type info) 'pointer))


;;;
;;; GI Bindings
;;;

(define g_field_info_get_flags
  (pointer->procedure unsigned-int
                      (dynamic-func "g_field_info_get_flags"
				    %libgirepository)
                      (list '*)))

(define g_field_info_get_offset
  (pointer->procedure int
                      (dynamic-func "g_field_info_get_offset"
				    %libgirepository)
                      (list '*)))

(define g_field_info_get_type
  (pointer->procedure '*
                      (dynamic-func "g_field_info_get_type"
				    %libgirepository)
                      (list '*)))


;;;
;;; Type and Values
;;;

(eval-when (expand load eval)
  (gi-cache-set! 'flags
                 'gi-field-info-flags
                 (make <gi-flags>
                   #:g-name  "GIFieldInfoFlags"
                   #:enum-set '((readable . 1)
                                (writable . 2)))))
