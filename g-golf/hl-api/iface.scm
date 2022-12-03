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


(define-module (g-golf hl-api iface)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf gi)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gi-iface-info-struct
            gi-iface-init-func-closure
            gi-iface-vfunc-closure

            ;; iface-init-func cache
            %gi-iface-init-func-cache
            gi-iface-init-func-cache-ref
            gi-iface-init-func-cache-set!
            gi-iface-init-func-cache-remove!
            gi-iface-init-func-cache-for-each
            gi-iface-init-func-cache-show

            ;; iface-info-struct cache
            %gi-iface-info-struct-cache
            gi-iface-info-struct-cache-ref
            gi-iface-info-struct-cache-set!
            gi-iface-info-struct-cache-remove!
            gi-iface-info-struct-cache-for-each
            gi-iface-info-struct-cache-show))


#;(g-export )

(define (gi-iface-info-struct iface-class)
  (let ((iface-info-struct-name
         (symbol-append (class-name->name (class-name iface-class))
                        '-info-struct))
        #;(iface-init-func-closure
         (gi-iface-init-func-closure (slot-ref iface-class 'info))))
  (or (gi-iface-info-struct-cache-ref iface-info-struct-name)
      (gi-iface-info-struct-cache-set!
       iface-info-struct-name
       (g-iface-info-struct-new)
       #;(g-iface-info-struct-new #:iface-init-func iface-init-func-closure)))))

(define (gi-iface-init-func-closure info)
  (let* ((module (resolve-module '(g-golf hl-api gobject)))
         (g-name (g-registered-type-info-get-type-name info))
         (name (g-name->name g-name))
         (iface-struct (g-interface-info-get-iface-struct info))
         (field-desc (and iface-struct
                          (gi-struct-field-desc iface-struct))))
    (match field-desc
      (#f
       (warning "No iface-struct:" g-name)
       %iface-init-func)
      ((g-iface . vfunc-field-desc)
       ;; The first field of a GInterface iface-struct is g-iface
       (let loop ((vfuncs vfunc-field-desc)
                  (vfunc-closure-desc '()))
         (match vfuncs
           (()
            (let ((iface-init-func-name (symbol-append name '-init-func))
                  (iface-init-func
                   (gi-iface-init-func-closure-1 vfunc-closure-desc)))
              (g-base-info-unref iface-struct)
              (gi-iface-init-func-cache-set! iface-init-func-name
                                             iface-init-func)
              iface-init-func))
           ((vfunc . rest)
            (loop rest
                  (cons (gi-iface-vfunc-closure name vfunc module)
                        vfunc-closure-desc)))))))))

(define (gi-iface-init-func-closure-1 vfunc-closure-desc)
  (procedure->pointer void
                      (lambda (g-iface iface-data)
                        (let loop ((vfuncs vfunc-closure-desc))
                          (match vfuncs
                            (() 'done)
                            ((vfunc . rest)
                             (match vfunc
                               ((vfunc-closure . iface-vtable-struct-offset)
                                (bv-ptr-set! (gi-pointer-inc g-iface
                                                             iface-vtable-struct-offset)
                                             vfunc-closure)))
                             (loop rest))))
                        (values))
                      (list '* '*)))

(define (gi-iface-vfunc-closure iface-name vfunc-field-desc module)
  (let ((%g-golf-vfunc-closure
         (@ (g-golf hl-api callback) g-golf-vfunc-closure)))
    (match vfunc-field-desc
      ((name type-tag iface-vtable-struct-offset flags)
       ;; not all, but most vfunc have a corresponding method. when this
       ;; procedure is called, they have been imported already. we retrieve it
       ;; and use the <function> instance (which has all the callable info we
       ;; need to make a callback), and the method itself, as this is what
       ;; users will specialize.
       (let* ((method-name (symbol-append iface-name '- name))
              (f-inst (gi-cache-ref 'function method-name))
              (method (and f-inst (module-ref module name)))
              ;; i initially thought all vfunc have a corresponding method,
              ;; but i was told on #introspection there are exceptions.
              (closure (if f-inst
                           (%g-golf-vfunc-closure method-name
                                                  f-inst
                                                  #;(lambda args (apply method args))
                                                  method)
                           (begin
                             (warning "VFunc with no corresponding method"
                                      (cons iface-name name))
                             %null-pointer))))
         (when (%debug)
           (dimfi 'vfunc-closure 'for: method-name)
           (dimfi "  " method)
           (dimfi "  " f-inst 'n-arg: (slot-ref f-inst 'n-arg))
           (dimfi "  " 'closure: closure 'offset: iface-vtable-struct-offset))
         (cons closure iface-vtable-struct-offset))))))


;;;
;;; The gi-iface-init-func-cache
;;;

(define %gi-iface-init-func-cache-default-size 1013)

(define %gi-iface-init-func-cache #f)
(define gi-iface-init-func-cache-ref #f)
(define gi-iface-init-func-cache-set! #f)
(define gi-iface-init-func-cache-remove! #f)
(define gi-iface-init-func-cache-for-each #f)
(define gi-iface-init-func-cache-show #f)

(eval-when (expand load eval)
  (let* ((%gi-iface-init-func-cache-default-size 1013)
         (gi-iface-init-func-cache (make-hash-table
                                    %gi-iface-init-func-cache-default-size))
         (gi-iface-init-func-mutex (make-mutex))
         (%gi-iface-init-func-cache-show-prelude
          "The iface-init-func cache entries are"))

    (set! %gi-iface-init-func-cache
          (lambda () gi-iface-init-func-cache))

    (set! gi-iface-init-func-cache-ref
          (lambda (name)
            (with-mutex gi-iface-init-func-mutex
              (hashq-ref gi-iface-init-func-cache name))))

    (set! gi-iface-init-func-cache-set!
          (lambda (name callback)
            (with-mutex gi-iface-init-func-mutex
              (hashq-set! gi-iface-init-func-cache name callback))))

    (set! gi-iface-init-func-cache-remove!
          (lambda (name)
            (with-mutex gi-iface-init-func-mutex
              (hashq-remove! gi-iface-init-func-cache name))))

    (set! gi-iface-init-func-cache-for-each
          (lambda (proc)
            (with-mutex gi-iface-init-func-mutex
              (hash-for-each proc
                  gi-iface-init-func-cache))))

    (set! gi-iface-init-func-cache-show
          (lambda* (#:optional (port (current-output-port)))
            (format port "~A~%"
                    %gi-iface-init-func-cache-show-prelude)
            (letrec ((show (lambda (key value)
                             (format port "  ~S  -  ~S~%"
                                     key
                                     value))))
              (gi-iface-init-func-cache-for-each show))))))


;;;
;;; The gi-iface-init-func-cache
;;;

(define %gi-iface-info-struct-cache #f)
(define gi-iface-info-struct-cache-ref #f)
(define gi-iface-info-struct-cache-set! #f)
(define gi-iface-info-struct-cache-remove! #f)
(define gi-iface-info-struct-cache-for-each #f)


(eval-when (expand load eval)
  (let* ((%gi-iface-info-struct-cache-default-size 1013)
         (gi-iface-info-struct-cache (make-hash-table
                                      %gi-iface-info-struct-cache-default-size))
         (gi-iface-info-struct-mutex (make-mutex))
         (%gi-iface-info-struct-cache-show-prelude
          "The iface-info-struct cache entries are"))

    (set! %gi-iface-info-struct-cache
          (lambda () gi-iface-info-struct-cache))

    (set! gi-iface-info-struct-cache-ref
          (lambda (name)
            (with-mutex gi-iface-info-struct-mutex
              (hashq-ref gi-iface-info-struct-cache name))))

    (set! gi-iface-info-struct-cache-set!
          (lambda (name callback)
            (with-mutex gi-iface-info-struct-mutex
              (hashq-set! gi-iface-info-struct-cache name callback))))

    (set! gi-iface-info-struct-cache-remove!
          (lambda (name)
            (with-mutex gi-iface-info-struct-mutex
              (hashq-remove! gi-iface-info-struct-cache name))))

    (set! gi-iface-info-struct-cache-for-each
          (lambda (proc)
            (with-mutex gi-iface-info-struct-mutex
              (hash-for-each proc
                             gi-iface-info-struct-cache))))

    (set! gi-iface-info-struct-cache-show
          (lambda* (#:optional (port (current-output-port)))
            (format port "~A~%"
                    %gi-iface-info-struct-cache-show-prelude)
            (letrec ((show (lambda (key value)
                             (format port "  ~S  -  ~S~%"
                                     key
                                     value))))
              (gi-iface-info-struct-cache-for-each show))))))
