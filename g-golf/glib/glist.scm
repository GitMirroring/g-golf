;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019
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


(define-module (g-golf glib glist)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  #:use-module (g-golf gi utils)

  #:export (g-list-parse
            g-list-data
            g-list-next
            g-list-prev

            g-list-prepend
            g-list-free
            g-list-free-full
            g-list-length
            g-list-nth-data))


;;;
;;; Glib Low level API
;;;

(define %g-list-struct-ptr
  (list '* '* '*))

(define %g-list-struct-int32
  (list int32 '* '*))

(define %g-list-struct-uint32
  (list uint32 '* '*))

(define (g-list-parse g-list type)
  (case type
    ((object
      utf8)
     (parse-c-struct g-list %g-list-struct-ptr))
    ((int32)
     (parse-c-struct g-list %g-list-struct-int32))
    ((uint32)
     (parse-c-struct g-list %g-list-struct-uint32))
    (else
     (error "Unkown glist type; " type))))

(define (g-list-data g-list type)
  (match (g-list-parse g-list type)
    ((data _ _) data)))

(define (g-list-next g-list type)
  (match (g-list-parse g-list type)
    ((_ next _) next)))

(define (g-list-prev g-list type)
  (match (g-list-parse g-list type)
    ((_ _ prev) prev)))

(define (g-list-prepend g-list data)
  (g_list_prepend (scm->gi g-list 'pointer)
                  (scm->gi data 'pointer)))

(define (g-list-free g-list)
  (g_list_free g-list))

(define (g-list-free-full g-list free-func)
  (g_list_free_full g-list
                    (scm->gi-pointer free-func)))

(define (g-list-length g-list)
  (g_list_length g-list))

(define (g-list-nth-data g-list n)
  (let ((foreign (g_list_nth_data g-list n)))
    (if (null-pointer? foreign)
        #f
        foreign)))


;;;
;;; Glib Bindings
;;;

(define g_list_prepend
  (pointer->procedure '*
                      (dynamic-func "g_list_prepend"
				    %libglib)
                      (list '*		;; g-slist
                            '*)))	;; data

(define g_list_free
  (pointer->procedure void
                      (dynamic-func "g_list_free"
				    %libglib)
                      (list '*)))

(define g_list_free_full
  (pointer->procedure void
                      (dynamic-func "g_list_free_full"
				    %libglib)
                      (list '*		;; list (first) ptr
                            '*)))	;; destroy notify free-func

(define g_list_length
  (pointer->procedure unsigned-int
                      (dynamic-func "g_list_length"
				    %libglib)
                      (list '*)))

(define g_list_nth_data
  (pointer->procedure '*
                      (dynamic-func "g_list_nth_data"
				    %libglib)
                      (list '*
                            unsigned-int)))
