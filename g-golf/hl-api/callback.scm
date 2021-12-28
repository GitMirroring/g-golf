;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2021
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


(define-module (g-golf hl-api callback)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf support libg-golf)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)
  
  #:export (gi-import-callback
            g-golf-callback-closure))


#;(g-export )


(define (gi-import-callback info)
  (dimfi (g-base-info-get-namespace info)
         (g-base-info-get-name info)
         " (callback)"))


;;;
;;; Dynamic FFI C closure for GICallbackInfo
;;;

(define (g-golf-callback-closure name info proc)
  (dimfi "g-golf-callback-closure")
  (dimfi "  " name " " (g-base-info-get-name info))
  (g_golf_callback_closure (string->pointer (symbol->string name))
                           info		;; a GICallbackInfo ptr
                           (scm->pointer proc)))
