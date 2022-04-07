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


(define-module (g-golf gi constant-info)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf gi common-types)
  #:use-module (g-golf gi base-info)
  #:use-module (g-golf gi type-info)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gi-import-constant

            g-constant-info-free-value
            g-constant-info-get-type
            g-constant-info-get-value))


;;;
;;;
;;;

(define* (gi-import-constant info)
  (let* ((g-name (g-base-info-get-name info))
         ;; (name (g-name->name g-name))
         (type-info (g-constant-info-get-type info))
         (type-tag (g-type-info-get-tag type-info))
         (field (gi-type-tag->field type-tag))
         (value (make-gi-argument))
         (dummy (g-constant-info-get-value info value))
         (constant (gi-argument-ref value field)))
    (g-base-info-unref type-info)
    (values constant
            g-name)))


;;;
;;; Low level API
;;;

(define (g-constant-info-free-value info value)
  (g_constant_info_free_value info value))

(define (g-constant-info-get-type info)
  (g_constant_info_get_type info))

(define (g-constant-info-get-value info value)
  (g_constant_info_get_value info value))


;;;
;;; GI Bindings
;;;

(define g_constant_info_free_value
  (pointer->procedure void
                      (dynamic-func "g_constant_info_free_value"
				    %libgirepository)
                      (list '*		;; info
                            '*)))	;; value

(define g_constant_info_get_type
  (pointer->procedure '*
                      (dynamic-func "g_constant_info_get_type"
				    %libgirepository)
                      (list '*)))	;; info

(define g_constant_info_get_value
  (pointer->procedure int
                      (dynamic-func "g_constant_info_get_value"
				    %libgirepository)
                      (list '*		;; info
                            '*)))	;; value
