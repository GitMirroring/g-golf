;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2018
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


(define-module (g-golf glib mem-alloc)
  #:use-module (system foreign)
  #:use-module (g-golf init)

  #:export (g-malloc
	    g-malloc0
	    g-free
            #;g-steal-pointer
	    g-memdup))


;;;
;;; Glib Low level API
;;;

(define (g-malloc n-bytes)
  (if (and (exact-integer? n-bytes)
           (not (negative? n-bytes)))
      (if (zero? n-bytes)
          #f
          (g_malloc n-bytes))
      (error "Wrong type argument: " n-bytes)))

(define (g-malloc0 n-bytes)
  (if (and (exact-integer? n-bytes)
           (not (negative? n-bytes)))
      (if (zero? n-bytes)
          #f
          (g_malloc0 n-bytes))
      (error "Wrong type argument: " n-bytes)))

(define (g-free mem)
  (g_free mem))

;; g_steal_pointer is unavailable in %libglib
#;(define (g-steal-pointer foreign)
  (g_steal_pointer foreign))

(define (g-memdup mem n-bytes)
  (if (and (exact-integer? n-bytes)
           (not (negative? n-bytes)))
      (if (or (null-pointer? mem)
              (zero? n-bytes))
          #f
          (g_memdup mem n-bytes))
      (error "Wrong type argument: " n-bytes)))


;;;
;;; Glib Bindings
;;;

(define g_malloc
  (pointer->procedure '*
                      (dynamic-func "g_malloc"
				    %libglib)
                      (list int)))

(define g_malloc0
  (pointer->procedure '*
                      (dynamic-func "g_malloc0"
				    %libglib)
                      (list int)))

(define g_free
  (pointer->procedure void
                      (dynamic-func "g_free"
				    %libglib)
                      (list '*)))

#;(define g_steal_pointer
  (pointer->procedure '*
                      (dynamic-func "g_steal_pointer"
				    %libglib)
                      (list '*)))

(define g_memdup
  (pointer->procedure '*
                      (dynamic-func "g_memdup"
				    %libglib)
                      (list '* int)))
