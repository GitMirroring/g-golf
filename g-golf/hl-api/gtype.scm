;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2018 - 2023
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

;; This code is largely inspired by the Guile-Gnome module (gnome
;; gobject gtype), see:

;;   https://www.gnu.org/software/guile-gnome

;;   http://git.savannah.gnu.org/cgit/guile-gnome.git
;;     tree/glib/gnome/gobject/gtype.scm

;;; Code:


(define-module (g-golf hl-api gtype)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 format)
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
  
  #:export (<gtype-class>
            <gtype-instance>

            g-type-class
            %g-inst-construct-g-type
            g-value-func-ref
            g-value-func-set
            scm->g-property))


(g-export !info
          !namespace
          !g-type
          !g-name
          !g-class
          !g-struct-fields
          !derived
          !set-value-func
          !set-value-func-ptr
          !g-value-set-proc
          !get-value-func
          !get-value-func-ptr
          !g-value-get-proc

          !g-inst
          unref
          #;g-inst-cache-remove!)


;;;
;;; 
;;;

;; The metaclass of all GType classes.

(define-class <gtype-class> (<class>)
  (info #:accessor !info #:init-keyword #:info)
  (namespace #:accessor !namespace #:init-value #f)
  (g-type #:accessor !g-type #:init-keyword #:g-type)
  (g-name #:accessor !g-name #:init-keyword #:g-name)
  (g-class #:accessor !g-class)
  (g-struct-fields #:accessor !g-struct-fields
                   #:init-keyword #:g-struct-fields #:init-value #f)
  (derived #:accessor !derived #:init-keyword #:derived #:init-value #f)
  (class-init-func-closure #:init-keyword #:class-init-func-closure #:init-value #f)
  (class-init-func #:init-keyword #:class-init-func #:init-value #f)
  (set-value-func #:accessor !set-value-func
                  #:init-keyword #:set-value-func #:init-value #f)
  (set-value-func-ptr #:accessor !set-value-func-ptr
                      #:init-keyword #:set-value-func-ptr #:init-value #f)
  (g-value-set-proc #:accessor !g-value-set-proc
                    #:init-keyword #:g-value-set-proc #:init-value #f)
  (get-value-func #:accessor !get-value-func
                  #:init-keyword #:get-value-func #:init-value #f)
  (get-value-func-ptr #:accessor !get-value-func-ptr
                      #:init-keyword #:get-value-func-ptr #:init-value #f)
  (g-value-get-proc #:accessor !g-value-get-proc
                    #:init-keyword #:g-value-get-proc #:init-value #f))

(define-method (initialize (self <gtype-class>) initargs)
  (let ((info (or (get-keyword #:info initargs #f)
                  (error "Missing #:info initarg: " initargs))))
    (next-method)
    (match info
      (#t 'done)		;; it is #t for gtype instances
      ((? pointer?)		;; a GI class definition
       (let* ((namespace (g-base-info-get-namespace info))
              (g-type (g-registered-type-info-get-g-type info))
              (g-name (g-registered-type-info-get-type-name info))
              (g-class (g-type-class info #:g-type g-type)))
         (mslot-set! self
                     'namespace namespace
                     'g-type g-type
                     'g-name g-name
                     'g-class g-class)
         (g-type-cache-set! g-type self)
         (and g-class
              (g-class-cache-set! g-class self))))
      ((? number?)		;; either a runtime or a derived class
       (let* ((g-type info)
              (g-name (g-type-name g-type))
              (g-class (g-type-class #f #:g-type g-type)))
         (mslot-set! self
                     'info #f
                     'g-type g-type
                     'g-name g-name
                     'g-class g-class)
         (g-type-cache-set! g-type self)
         (and g-class
              (g-class-cache-set! g-class self)))))))

(define* (g-type-class info #:key (g-type #f))
  (let* ((g-type (or g-type
                     (g-registered-type-info-get-g-type info)))
         (g-f-type (g-type-fundamental g-type))
         (g-class (case (g-type->symbol g-f-type)
                    ((object)
                     (g-type-class-ref g-type))
                    (else
                     #f))))
    (and g-class
         (g-type-class-unref g-class))
    g-class))

;; The root class of all instantiable GType classes.

(define-class <gtype-instance> ()
  (g-inst #:accessor !g-inst)
  #:info #t
  #:metaclass <gtype-class>)

;; Implementing a toggle ref mechanism in g-golf, this version of the
;; specialized make method has a branch that should normally never ever
;; be 'reached' again - keeping the code to compare, I'll drop it when
;; everything is under control using the toggle ref mechanism.

#;(define-method (make (class <gtype-class>) . initargs)
  ;; If #:g-inst is passed, we first check if the g-inst is cached, in
  ;; which case we just the goops instance associated with it, unless we
  ;; detect that the cache holds an entry that is no longer valid, as
  ;; further explained here below.
  (let* ((g-inst (get-keyword #:g-inst initargs #f))
         (inst (and g-inst
                    (g-inst-cache-ref g-inst))))
    (if inst
        (let* ((its-class (class-of inst))
               (derived? (!derived its-class)))
          (if (or derived?
                  (eq? its-class class))
              inst
              (begin
                ;; This means that g-inst points to a new gobject
                ;; instance, but g-golf's cache still has the 'old'
                ;; entry, this may happen if no gc occurrred yet, but
                ;; glib/gobject already recovered the memory and is
                ;; using it ...
                (g-inst-cache-remove! g-inst)
                (next-method))))
        (next-method))))

(define-method (make (class <gtype-class>) . initargs)
  ;; If #:g-inst is passed, we first check if the g-inst is cached, in
  ;; which case we just the goops instance associated with it.
  (let* ((g-inst (get-keyword #:g-inst initargs #f))
         (inst (and g-inst
                    (g-inst-cache-ref g-inst))))
    (if inst
        (let* ((its-class (class-of inst))
               (derived? (!derived its-class)))
          (if (or derived?
                  (eq? its-class class))
              inst
              ;; Should not be possible anymore, as g-golf is now using
              ;; the toggle ref mechanism.
              (scm-error 'impossible #f "Invalid g-inst-cache entry detected: ~S"
                         (list inst) #f)))
        (next-method))))

#!

;; Implementing a toggle ref mechanism in g-golf, the g-inst-cache
;; becomes a normal hash-table and we do not need a g-inst-guard
;; anymore. Keeping the code (as an example).

(define-syntax make-g-inst-guard
  (syntax-rules ()
    ((make-g-inst-guard)
     (let ((guardian (make-guardian)))
       (add-hook! after-gc-hook
                  (lambda ()
                    #;(dimfi guardian)
                    (let loop ()
                      (let ((inst (guardian)))
                        (when inst
                          (let ((g-inst (!g-inst inst)))
                            #;(dimfi "  gc" inst
                                   "[ g-object ref-count before cleaning"
                                   (g-object-ref-count g-inst) "]")
                            (g-object-unref g-inst)
                            (loop)))))))
       (lambda (g-inst inst)
         (g-inst-cache-set! g-inst inst)
         (guardian inst)
         inst)))))

(define g-inst-guard (make-g-inst-guard))

(define-method (initialize (self <gtype-instance>) initargs)
  (let* ((class (class-of self))
         (g-type (!g-type class))
         (g-type-name (g-type->symbol (g-type-fundamental g-type))))
    (receive (split-kw split-rest)
        (split-keyword-args (map slot-definition-init-keyword
                              (class-g-property-slots class))
                            initargs)
      (let ((g-inst (or (get-keyword #:g-inst initargs #f)
                        (g-inst-construct self split-kw))))
        (next-method self split-rest)
        (case g-type-name
          ((object) ;; [not when interface]
           (when (g-object-is-floating g-inst)
             (g-object-ref-sink g-inst))))
        (set! (!g-inst self) g-inst)
        (g-inst-guard g-inst self)))))

!#

;; Monitoring 'things - just keeping the code
#;(dimfi (if (gi->scm is-last-ref 'boolean)
           'last-ref
           'not-the-last-ref)
        (g-inst-cache-ref object)
        (g-object-ref-count object))

(define (g-toggle-notify data object is-last-ref)
  (when (gi->scm is-last-ref 'boolean)
    (g-object-remove-toggle-ref object %g-toggle-notify #f)
    (g-inst-cache-remove! object)))

(define %g-toggle-notify
  (procedure->pointer void
                      g-toggle-notify
                      (list '*		;; data
                            '*		;; *object
                            int)))	;; is-last-ref

(define-method (initialize (self <gtype-instance>) initargs)
  (let* ((class (class-of self))
         (g-type (!g-type class))
         (g-type-name (g-type->symbol (g-type-fundamental g-type))))
    (receive (split-kw split-rest)
        (split-keyword-args (map slot-definition-init-keyword
                              (class-g-property-slots class))
                            initargs)
      (let* ((g-inst? (get-keyword #:g-inst initargs #f))
             (g-inst (or g-inst?
                        (g-inst-construct self split-kw))))
        (next-method self split-rest)
        (set! (!g-inst self) g-inst)
        (g-inst-cache-set! g-inst self)
        (case g-type-name
          ((object) ;; [not when interface]
           (when (g-object-is-floating g-inst)
             (g-object-ref-sink g-inst))
           (g-object-add-toggle-ref g-inst %g-toggle-notify #f)))
        (initialize-g-param-slots self)
        (unless (null? (class-child-id-slots class))
          (initialize-child-id-slots self))))))

(define (initialize-g-param-slots inst)
  (let* ((class (class-of inst))
         (g-class (!g-class class)))
    (for-each (lambda (item)
                (match item
                  ((g-class g-param-slots)
                   (for-each
                       (lambda (slot)
                         (let* ((name (slot-definition-name slot))
                                (p-name (symbol->string name))
                                (p-spec (g-object-class-find-property g-class p-name))
                                (p-spec-default (g-param-spec-get-default-value p-spec))
                                (default (g-value-ref p-spec-default))
                                (name_ (symbol-append name '_)))
                           (slot-set! inst name_ default)))
                       g-param-slots))))
        (g-class-g-param-slots class))))

(define (g-class-g-param-slots class)
  (filter-map (lambda (c)
                (let ((g-param-direct-slots
                       (class-direct-g-param-slots c)))
                  (if (null? g-param-direct-slots)
                      #f
                      (list (!g-class c)
                            g-param-direct-slots))))
      (class-precedence-list class)))

(define (initialize-child-id-slots inst)
  (let* ((module (resolve-module '(g-golf hl-api function)))
         (get-template-child
          (module-ref module 'gtk-widget-get-template-child)))
    (for-each (lambda (cpl-class)
                (for-each (lambda (slot)
                            (let* ((options (slot-definition-options slot))
                                   (name (get-keyword #:name options))
                                   (child-id (get-keyword #:child-id options)))
                              (slot-set! inst
                                         name
                                         (get-template-child inst
                                                             (!g-type cpl-class)
                                                             child-id))))
                    (class-direct-child-id-slots cpl-class)))
        (class-precedence-list (class-of inst)))))

(define %g_value_init
  (@@ (g-golf gobject generic-values) g_value_init))


(define %g-inst-construct-g-type (make-parameter #f))

(define-method (g-inst-construct (self <gtype-instance>)
                                 g-property-initargs)
  (let ((g-type (!g-type (class-of self))))
    (parameterize ((%g-inst-construct-g-type g-type))
      (if (null? g-property-initargs)
          (g-object-new g-type)
          (let* ((slot-def-init-val-pairs
                  (slot-definition-init-value-pairs self g-property-initargs))
                 (n-prop (length slot-def-init-val-pairs))
                 (%g-value-size (g-value-size))
                 (g-values (bytevector->pointer
                            (make-bytevector (* n-prop %g-value-size) 0)))
                 (names
                  (let loop ((i 0)
                             (names '())
                             (g-value g-values)
                             (slot-def-init-val-pairs slot-def-init-val-pairs))
                    (match slot-def-init-val-pairs
                      (()
                       (reverse! names))
                      ((slot-def-init-val-pair . rest)
                       (match slot-def-init-val-pair
                         ((slot-def . init-val)
                          (let* ((slot-opts (slot-definition-options slot-def))
                                 (g-name (get-keyword #:g-name slot-opts #f))
                                 (g-type (get-keyword #:g-type slot-opts #f)))
                            (%g_value_init g-value g-type)
                            (match (g-type->symbol g-type)
                              (#f
                               ;; Most likely a fundamental type that is not in GObject.
                               (g-value-func-set g-value g-type init-val))
                              (else
                               (g-value-set! g-value
                                             (scm->g-property g-type init-val))))
                            (loop (+ i 1)
                                  (cons g-name names)
                                  (gi-pointer-inc g-value %g-value-size)
                                  rest)))))))))
            (g-object-new-with-properties g-type
                                          n-prop
                                          (scm->gi names 'strings)
                                          g-values))))))

(define (g-value-func-ref g-value g-type)
  (let ((class (g-type-cache-ref g-type)))
    (if class
        (let ((g-value-get-proc (!g-value-get-proc class)))
          (if g-value-get-proc
              (values (g-value-get-proc g-value) class)
              (scm-error 'failed #f "Undefined g-value-get-proc for g-type: ~A"
                   (list g-type) #f)))
        (scm-error 'failed #f "Undefined class for g-type: ~A"
                   (list g-type) #f))))

(define (g-value-func-set g-value g-type value)
  (let ((class (g-type-cache-ref g-type)))
    (if class
        (let ((g-value-set-proc (!g-value-set-proc class)))
          (if g-value-set-proc
              (g-value-set-proc g-value (!g-inst value))
              (scm-error 'failed #f "Undefined g-value-set-proc for g-type: ~A"
                   (list g-type) #f)))
        (scm-error 'failed #f "Undefined class for g-type: ~A"
                   (list g-type) #f))))

(define (scm->g-property g-type value)
  (let ((g-type (if (symbol? g-type)
                    g-type
                    (g-type->symbol g-type))))
    (case g-type
      ((object)
       (and value
            (!g-inst value)))
      ((interface)
       (and value
            (if (pointer? value)
                value
                ;; It is (should be) an instance
                (!g-inst value))))
      (else
       value))))

(define-method (slot-definition-init-value-pairs (self <gtype-instance>)
                                                 initargs)
  (let ((class (class-of self)))
    (let loop ((initargs initargs)
               (results '()))
      (match initargs
        (()
         (reverse! results))
        ((kw val . rest)
         (loop rest
               (cons (cons (class-slot-definition class
                                                  (keyword->symbol kw))
                           val)
                     results)))))))

(define-method (unref (self <gtype-instance>))
  ;; Users should normally never call this method, and never call
  ;; g-object-unref directly either - it merely exists for debugging
  ;; and/or monitoring purposes.
  (g-object-unref (!g-inst self)))


;;;
;;; Instance cache methods 'completion'
;;;

#!

;; We don't need those anymore, as g-golf now implements a toggle
;; reference mechanism, nor users nor g-golf (outside the toggle
;; reference mechanism) should never ever have to call any of the g-inst
;; cache procedures.

(define-method (g-inst-cache-remove! (self <foreign>))
  (hashq-remove! %g-inst-cache
                 (pointer-address self)))

(define-method* (g-inst-cache-remove! (self <gtype-instance>)
                                      #:optional (g-inst #f))
  (hashq-remove! %g-inst-cache
                 (pointer-address (or g-inst
                                      (!g-inst self)))))

!#
