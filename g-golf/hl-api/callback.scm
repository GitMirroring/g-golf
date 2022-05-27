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


(define-module (g-golf hl-api callback)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf support libg-golf)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api events)
  #:use-module (g-golf hl-api argument)
  #:use-module (g-golf hl-api ccc)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gi-import-callback

            g-golf-callback-closure

            ;; <callback> inst cache
            gi-callback-inst-cache-ref
            gi-callback-inst-cache-set!
            gi-callback-inst-cache-remove!
            gi-callback-inst-cache-for-each
            gi-callback-inst-cache-show

            ;; callabck (user) closure cache
            gi-callback-closure-cache-ref
            gi-callback-closure-cache-set!
            gi-callback-closure-cache-remove!
            gi-callback-closure-cache-for-each
            gi-callback-closure-cache-show))


#;(g-export )


(define (gi-import-callback info)
  (let* ((namespace (g-base-info-get-namespace info))
         (g-name (g-base-info-get-name info))
         (name (g-name->name g-name)))
    (dimfi 'import-callback namespace name)
    (or (gi-callback-inst-cache-ref name)
        (let ((callback (make <callback> #:info info
                              #:namespace namespace
                              #:g-name g-name
                              #:name name)))
          ;; Do not (g-base-info-)unref the callback info - it is
          ;; required when invoked.
          (gi-callback-inst-cache-set! name callback)
          callback))))

(define-method (initialize (self <callback>) initargs)
  (let ((info (or (get-keyword #:info initargs #f)
                  (error "Missing #:info initarg: " initargs)))
        (namespace (get-keyword #:name initargs #f))
        (name (get-keyword #:name initargs #f)))
    (if name
        (next-method)
        (let* ((namespace (g-base-info-get-namespace info))
               (g-name (g-base-info-get-name info))
               (name (g-name->name g-name)))
          (next-method self
                       (append initargs
                               `(#:namespace ,namespace
                                 #:g-name ,g-name
                                 #:name ,name)))))))


;;;
;;; Dynamic FFI C closure for GICallbackInfo
;;;

(define (g-golf-callback-closure name info proc)
  (dimfi "g-golf-callback-closure")
  (dimfi "  " name " " (g-base-info-get-name info))
  (let ((callback (gi-import-callback info)))
    (describe callback))
  ;; Currently returns NULL - Wip ...
  (g_golf_callback_closure (string->pointer (symbol->string name))
                           info		;; a GICallbackInfo ptr
                           (scm->pointer proc)))


;;;
;;; The gi-callback-inst-cache
;;;

(define %gi-callback-inst-cache-default-size 1013)

(define %gi-callback-inst-cache #f)
(define gi-callback-inst-cache-ref #f)
(define gi-callback-inst-cache-set! #f)
(define gi-callback-inst-cache-remove! #f)
(define gi-callback-inst-cache-for-each #f)

(let* ((gi-callback-size %gi-callback-inst-cache-default-size)
       (gi-callback-inst-cache (make-hash-table
                                %gi-callback-inst-cache-default-size))
       (gi-callback-inst-mutex (make-mutex)))

  (set! %gi-callback-inst-cache
        (lambda () gi-callback-inst-cache))

  (set! gi-callback-inst-cache-ref
        (lambda (name)
          (with-mutex gi-callback-inst-mutex
            (hashq-ref gi-callback-inst-cache name))))

  (set! gi-callback-inst-cache-set!
        (lambda (name callback)
          (with-mutex gi-callback-inst-mutex
            (hashq-set! gi-callback-inst-cache name callback))))

  (set! gi-callback-inst-cache-remove!
        (lambda (name)
          (with-mutex gi-callback-inst-mutex
            (hashq-remove! gi-callback-inst-cache name))))

  (set! gi-callback-inst-cache-for-each
        (lambda (proc)
          (with-mutex gi-callback-inst-mutex
            (hash-for-each proc
                           gi-callback-inst-cache)))))

(define %gi-callback-inst-cache-show-prelude
  "The <callback> inst cache entries are")

(define* (gi-callback-inst-cache-show #:optional
                                      (port (current-output-port)))
  (format port "~A~%"
          %gi-callback-inst-cache-show-prelude)
  (letrec ((show (lambda (key value)
                   (format port "  ~S  -  ~S~%"
                           key
                           value))))
    (gi-callback-inst-cache-for-each show)))
