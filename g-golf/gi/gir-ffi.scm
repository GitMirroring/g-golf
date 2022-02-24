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
  #:use-module (g-golf gi utils)

  #:export (#;g-callable-info-prepare-closure))


;;;
;;; Low level API
;;;

;; Not ready for export yet - actually not even sure i'll use it, i may
;; solve this ffi callback prepare closure using libguile or manually
;; binding the ffi.hapi i need, we'll see.
#;(define (g-callable-info-prepare-closure info cif callback user-data)
  (gi->scm (g_callable_info_prepare_closure info cif callback user-data)
           'pointer))


;;;
;;; GI Bindings
;;;

(define g_callable_info_prepare_closure
  (pointer->procedure '*		;; *ffi-closure
                      (dynamic-func "g_callable_info_get_return_type"
				    %libgirepository)
                      (list '*		;; *callback-info
                            '*		;; *ffi-cif
                            '*		;; the ffi callback
                            '*)))	;; user-data
