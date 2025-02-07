;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2015
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


(define-module (g-golf gi typelib)
  #:use-module (ice-9 binary-ports)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  #:use-module (g-golf glib)
  #:use-module (g-golf gi utils)

  #:export (g-golf-typelib-new
	    call-with-input-typelib
	    g-typelib-new-from-memory
	    g-typelib-free
	    ;; g-typelib-symbol
	    g-typelib-get-name-space))


;;;
;;; Utils [None GI Low Level API]
;;;

(define (g-golf-typelib-new filename)
  (let* ((bv (call-with-input-file filename get-bytevector-all #:binary #t))
	 (bv-pointer (bytevector->pointer bv))
	 (bv-length (bytevector-length bv))
	 (g-bv (g-memdup bv-pointer bv-length)))
    (with-g-error g-error
		  (g-typelib-new-from-memory g-bv bv-length g-error))))

(define (call-with-typelib proc typelib)
  (call-with-values
      (lambda () (proc typelib))
    (lambda vals
      (g-typelib-free typelib)
      (apply values vals))))

(define (call-with-input-typelib file proc)
  (call-with-typelib proc (g-golf-typelib-new file)))


;;;
;;; Low level API
;;;

(define (g-typelib-new-from-memory bv-pointer bv-length g-error)
  (g_typelib_new_from_memory bv-pointer bv-length g-error))

(define (g-typelib-free typelib)
  (g_typelib_free typelib))

(define (g-typelib-get-name-space typelib)
  (gi->scm (g_typelib_get_namespace typelib) 'string))


;;;
;;; GI Bindings
;;;

(define g_typelib_new_from_memory
  (pointer->procedure '*
                      (dynamic-func "g_typelib_new_from_memory"
				    %libgirepository)
                      (list '* int '*)))

(define g_typelib_free
  (pointer->procedure void
                      (dynamic-func "g_typelib_free"
				    %libgirepository)
                      (list '*)))

(define g_typelib_get_namespace
  (pointer->procedure '*
                      (dynamic-func "g_typelib_get_namespace"
				    %libgirepository)
                      (list '*)))
