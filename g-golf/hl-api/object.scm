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


(define-module (g-golf hl-api object)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  ;; #:use-module (g-golf hl-api function)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)
  
  #:export (gi-import-object
            gi-import-interface

            ;; iface-init-func cache
            gi-iface-init-func-cache-ref
            gi-iface-init-func-cache-set!
            gi-iface-init-func-cache-remove!
            gi-iface-init-func-cache-for-each
            gi-iface-init-func-cache-show

            ;; iface-info-struct cache
            gi-iface-info-struct-cache-ref
            gi-iface-info-struct-cache-set!
            gi-iface-info-struct-cache-remove!
            gi-iface-info-struct-cache-for-each
            gi-iface-info-struct-cache-show))


#;(g-export )

(define* (gi-import-object info #:key (with-methods? #t) (force? #f))
  (let* ((namespace (g-base-info-get-namespace info))
         (with-methods? (if (gi-namespace-import-exception? namespace)
                            #f
                            with-methods?))
         (module (resolve-module '(g-golf hl-api gobject)))
         (r-info-cpl (g-object-info-cpl info #:reversed-order? #t)))
    (unless (is-g-object-subclass? r-info-cpl)
      ;; A 'fundamental type' class, not a GObject subclass. We need to
      ;; create the parent 'of all', which is the first element of the
      ;; reversed info-cpl list computed above. It could very well be
      ;; that the class has no child, but we need to created it before
      ;; to run the following code, which parse the r-info-cpl assuming
      ;; the parent class always exists - what must exist, to be
      ;; precise, is the corresponding goops class.
      (match r-info-cpl
        ((parent . rest)
         (g-object-import-with-supers parent '() module
                                      #:with-methods? with-methods?
                                      #:force? force?))))
    (let loop ((r-info-cpl r-info-cpl))
      (match r-info-cpl
        ((item)
         ;; by the very definition of this procedure, (a) the above
         ;; code, (b) the fact that <gobject> is part of g-golf and (c)
         ;; and the definition of this loop, last item of the r-info-cpl
         ;; - which could very well be the unique item - has been created,
         ;; Here, we just retrieve it.
         (match item
           ((info namespace name)
            (module-ref module
                        (g-name->class-name name)))))
        ((parent child . rest)
         (match parent
           ((p-info p-namespace p-name)
            (let* ((p-r-type (g-registered-type-info-get-g-type p-info))
                   (p-g-name (g-type-name p-r-type))
                   (p-c-name (g-name->class-name p-g-name))
                   (interfaces (gi-import-object-interfaces info
                                                            #:with-methods? with-methods?
                                                            #:force? force?))
                   (child-class
                    (g-object-import-with-supers child
                                                 (cons (module-ref module p-c-name)
                                                       interfaces)
                                                 module
                                                 #:with-methods? with-methods?
                                                 #:force? force?)))
                  (loop (cons child rest))))))))))

(define (is-g-object-subclass? info-cpl)
  (letrec ((is-g-object-info-cpl-item?
            (lambda (what info-cpl-item)
              (match info-cpl-item
                ((info namespace name)
                 (string=? name what))))))
    (member "GObject" info-cpl is-g-object-info-cpl-item?)))

(define* (g-object-import-with-supers child supers module
                                      #:key (with-methods? #t) (force? #f))
  (match child
    ((info namespace name)
     (unless (member namespace
                     (g-irepository-get-loaded-namespaces)
                     string=?)
       (g-irepository-require namespace))
     (let* ((r-type (g-registered-type-info-get-g-type info))
            (g-name (g-type-name r-type))
            (c-name (g-name->class-name g-name)))
       (if (module-bound? module c-name)
           (module-ref module c-name)
           (let ((public-i (module-public-interface module))
                 (c-inst (make-class supers
                                     '()
                                     #:name c-name
                                     #:info info)))
             (module-define! module c-name c-inst)
             (module-add! public-i c-name
                          (module-variable module c-name))
             (when with-methods?
               (gi-import-object-methods info #:force? force?)
               (gi-import-object-class-methods info #:force? force?))
             ;; We do not import signals, they are imported on
             ;; demand. Visit (g-golf hl-api signal) signal-connect and
             ;; the %gi-signal-cache related code to see how this is
             ;; achieved.
             #;(gi-import-object-signals info)
             c-inst))))))

(define* (g-object-info-cpl info #:key (reversed-order? #f))
  (let  loop ((parent (g-object-info-get-parent info))
              (results (list (list info
                                   (g-base-info-get-namespace info)
                                   (g-object-info-get-type-name info)))))
    (if (not parent)
        (if reversed-order? results (reverse! results))
        (loop (g-object-info-get-parent parent)
              (cons (list parent
                          (g-base-info-get-namespace parent)
                          (g-object-info-get-type-name parent))
                    results)))))

(define* (gi-import-object-methods info
                                   #:key (force? #f))
  (let ((%gi-import-function
         (@ (g-golf hl-api function) gi-import-function))
        (namespace (g-base-info-get-namespace info))
        (n-method (g-object-info-get-n-methods info)))
    (do ((i 0
            (+ i 1)))
        ((= i n-method))
      (let* ((m-info (g-object-info-get-method info i))
             (name (g-function-info-get-symbol m-info)))
        ;; Some methods listed here are functions: (a) their flags is an
        ;; empty list; (b) they do not expect an additional instance
        ;; argument (their GIargInfo list is complete); (c) they have a
        ;; GIFuncInfo entry in the namespace (methods do not). We do not
        ;; (re)import those here.
        (unless (g-irepository-find-by-name namespace name)
          (%gi-import-function m-info #:force? force?))))))

(define* (gi-import-object-class-methods info
                                         #:key (force? #f))
  (let ((%gi-import-function
         (@ (g-golf hl-api function) gi-import-function))
        (namespace (g-base-info-get-namespace info))
        (class-struct (g-object-info-get-class-struct info)))
    (when class-struct
      (let ((n-method (g-struct-info-get-n-methods class-struct)))
        (do ((i 0
                (+ i 1)))
            ((= i n-method))
          (let* ((m-info (g-struct-info-get-method class-struct i))
                 (name (g-function-info-get-symbol m-info)))
            ;; Some methods listed here are functions: (a) their flags is an
            ;; empty list; (b) they do not expect an additional instance
            ;; argument (their GIargInfo list is complete); (c) they have a
            ;; GIFuncInfo entry in the namespace (methods do not). We do not
            ;; (re)import those here.
            (unless (g-irepository-find-by-name namespace name)
              (%gi-import-function m-info #:force? force?))))))))

#!

;; As said above, we do not import signals, they are imported on
;; demand. Visit (g-golf hl-api signal) signal-connect and the
;; %gi-signal-cache related code to see how this is achieved.

(define (gi-import-object-signals info)
  (let ((n-signal (g-object-info-get-n-signals info)))
    #;(dimfi (g-object-info-get-type-name info)
           " " n-signal "signals")
    (do ((i 0
            (+ i 1)))
        ((= i n-signal))
      (let ((s-info (g-object-info-get-signal info i)))
        #;(dimfi "  " (g-base-info-get-namespace s-info)
               (g-base-info-get-name s-info)
               " (signal)")
        'wip))))

!#


;;;
;;; Interfaces
;;;

(define* (gi-import-object-interfaces info
                                      #:key (with-methods? #t) (force? #f))
  (let loop ((n-iface (g-object-info-get-n-interfaces info))
             (i 0)
             (results '()))
    (if (= i n-iface)
        (reverse! results)
        (loop n-iface
              (+ i 1)
              (cons (gi-import-interface (g-object-info-get-interface info i)
                                         #:with-methods? with-methods?
                                         #:force? force?)
                    results)))))

(define* (gi-import-interface info #:key (with-methods? #t) (force? #f))
  (let* ((namespace (g-base-info-get-namespace info))
         (with-methods? (if (gi-namespace-import-exception? namespace)
                            #f
                            with-methods?))
         (module (resolve-module '(g-golf hl-api gobject))))
    (unless (member namespace
                    (g-irepository-get-loaded-namespaces)
                    string=?)
      (g-irepository-require namespace))
    (let* ((r-type (g-registered-type-info-get-g-type info))
           (g-name (g-type-name r-type))
           (c-name (g-name->class-name g-name)))
      (if (module-bound? module c-name)
          (module-ref module c-name)
          (let ((public-i (module-public-interface module))
                (c-inst (make-class `(,<ginterface>)
                                     '()
                                     #:name c-name
                                     #:info info)))
             (module-define! module c-name c-inst)
             (module-add! public-i c-name
                          (module-variable module c-name))
             (when with-methods?
               (gi-import-interface-methods info #:force? force?)
               (let ((iface-info-struct-name
                      (symbol-append (g-name->name g-name) '-info-struct)))
                 (gi-iface-info-struct-cache-set! iface-info-struct-name
                                                  (g-iface-info-struct-new
                                                   (gi-iface-init-func-closure info)))))
             ;; We do not import signals, they are imported on
             ;; demand. Visit (g-golf hl-api signal) signal-connect and
             ;; the %gi-signal-cache related code to see how this is
             ;; achieved.
             #;(gi-import-interface-signals info)
             c-inst)))))

(define* (gi-import-interface-methods info
                                      #:key (force? #f))
  (let ((%gi-import-function
         (@ (g-golf hl-api function) gi-import-function))
        (namespace (g-base-info-get-namespace info))
        (n-method (g-interface-info-get-n-methods info)))
    (do ((i 0
            (+ i 1)))
        ((= i n-method))
      (let* ((m-info (g-interface-info-get-method info i))
             (name (g-function-info-get-symbol m-info)))
        ;; Some methods listed here are functions: (a) their flags is an
        ;; empty list; (b) they do not expect an additional instance
        ;; argument (their GIargInfo list is complete); (c) they have a
        ;; GIFuncInfo entry in the namespace (methods do not). We do not
        ;; (re)import those here.
        (unless (g-irepository-find-by-name namespace name)
          (%gi-import-function m-info #:force? force?))))))

(define (gi-iface-init-func-closure info)
  (let* ((g-name (g-registered-type-info-get-type-name info))
         (name (g-name->name g-name))
         (iface-struct (g-interface-info-get-iface-struct info))
         (field-desc (gi-struct-field-desc iface-struct))
         (module (resolve-module '(g-golf hl-api gobject))))
    (match field-desc
      ((g-iface . vfunc-field-desc)
       (let loop ((vfuncs vfunc-field-desc)
                  (vfunc-closure-desc '()))
         (match vfuncs
           (()
            (let ((iface-init-func-name (symbol-append name '-init-func))
                  (iface-init-func
                   (gi-iface-init-func-closure-1 vfunc-closure-desc)))
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
                                 ((vfunc-closure . iface-struct-offset)
                                  (bv-ptr-set! (gi-pointer-inc g-iface
                                                               iface-struct-offset)
                                               vfunc-closure)))
                               (loop rest))))
                          (values))
                        (list '* '*)))

(define (gi-iface-vfunc-closure iface-name vfunc-field-desc module)
  (let ((%g-golf-vfunc-closure
         (@ (g-golf hl-api callback) g-golf-vfunc-closure)))
    (match vfunc-field-desc
      ((name type-tag iface-struct-offset flags)
       ;; all vfunc have a corresponding method. when this procedure is called,
       ;; they have been imported already. we retrieve it and use the <function>
       ;; instance (which has all the callable info we need to make a callback),
       ;; and the method itself, as this is what users will specialize.
       (let* ((method-name (symbol-append iface-name '- name))
              (method (module-ref module name))
              (f-inst (gi-cache-ref 'function method-name))
              (closure (%g-golf-vfunc-closure method-name
                                              f-inst
                                              (lambda args (apply method args)))))
         (when (%debug)
           (dimfi 'vfunc-closure 'for: method-name)
           (dimfi "  " method)
           (dimfi "  " f-inst 'n-arg: (slot-ref f-inst 'n-arg))
           (dimfi "  " 'closure: closure 'offset: iface-struct-offset))
         (cons closure iface-struct-offset))))))


;;;
;;; The gi-iface-init-func-cache
;;;

(define %gi-iface-init-func-cache-default-size 1013)

(define %gi-iface-init-func-cache #f)
(define gi-iface-init-func-cache-ref #f)
(define gi-iface-init-func-cache-set! #f)
(define gi-iface-init-func-cache-remove! #f)
(define gi-iface-init-func-cache-for-each #f)

(let* ((cache-size %gi-iface-init-func-cache-default-size)
       (gi-iface-init-func-cache (make-hash-table
                                %gi-iface-init-func-cache-default-size))
       (gi-iface-init-func-mutex (make-mutex)))

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
                           gi-iface-init-func-cache)))))

(define %gi-iface-init-func-cache-show-prelude
  "The iface-init-func cache entries are")

(define* (gi-iface-init-func-cache-show #:optional
                                        (port (current-output-port)))
  (format port "~A~%"
          %gi-iface-init-func-cache-show-prelude)
  (letrec ((show (lambda (key value)
                   (format port "  ~S  -  ~S~%"
                           key
                           value))))
    (gi-iface-init-func-cache-for-each show)))


;;;
;;; The gi-iface-init-func-cache
;;;

(define %gi-iface-info-struct-cache-default-size 1013)

(define %gi-iface-info-struct-cache #f)
(define gi-iface-info-struct-cache-ref #f)
(define gi-iface-info-struct-cache-set! #f)
(define gi-iface-info-struct-cache-remove! #f)
(define gi-iface-info-struct-cache-for-each #f)

(let* ((cache-size %gi-iface-info-struct-cache-default-size)
       (gi-iface-info-struct-cache (make-hash-table
                                %gi-iface-info-struct-cache-default-size))
       (gi-iface-info-struct-mutex (make-mutex)))

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
                           gi-iface-info-struct-cache)))))

(define %gi-iface-info-struct-cache-show-prelude
  "The iface-info-struct cache entries are")

(define* (gi-iface-info-struct-cache-show #:optional
                                        (port (current-output-port)))
  (format port "~A~%"
          %gi-iface-info-struct-cache-show-prelude)
  (letrec ((show (lambda (key value)
                   (format port "  ~S  -  ~S~%"
                           key
                           value))))
    (gi-iface-info-struct-cache-for-each show)))
