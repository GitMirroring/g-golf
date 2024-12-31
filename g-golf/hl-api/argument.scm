;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023 - 2024
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


(define-module (g-golf hl-api argument)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-4)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api ccc)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<argument>

            type-description
            registered-type->gi-type
            gi-import-enum
            gi-import-flags
            gi-import-struct
            gi-import-union))


(g-export describe
          !type-info
          !g-name
          !name
          !closure
          !destroy
          !direction
          !transfer
          !scope
          !type-tag
          !type-desc
          !is-enum?
          !al-arg?
          !sub-type-desc
          !forced-type
          !string-pointer
          !callback-closure
          !bv-cache
          !bv-cache-ptr
          !is-pointer?
          !may-be-null?
          !is-caller-allocate?
          !is-optional?
          !is-return-value?
          !is-skip?
          !arg-pos
          !gi-argument-in
          !gi-argument-in-bv-pos
          !gi-argument-out
          !gi-argument-out-bv-pos
          !gi-argument-field)


;;;
;;; 
;;;

(define-class <argument> ()
  (type-info #:accessor !type-info #:init-value #f)
  (g-name #:accessor !g-name #:init-keyword #:g-name)
  (name #:accessor !name #:init-keyword #:name)
  (closure #:accessor !closure)
  (destroy #:accessor !destroy)
  (direction #:accessor !direction #:init-keyword #:direction)
  (transfer #:accessor !transfer
            #:init-keyword #:transfer #:init-value 'n/a)
  (scope #:accessor !scope)
  (type-tag #:accessor !type-tag #:init-keyword #:type-tag)
  (type-desc #:accessor !type-desc #:init-keyword #:type-desc)
  (is-enum? #:accessor !is-enum? #:init-keyword #:is-enum?)
  (al-arg? #:accessor !al-arg? #:init-value #f)
  (sub-type-desc #:accessor !sub-type-desc)
  (forced-type #:accessor !forced-type #:init-keyword #:forced-type)
  (string-pointer #:accessor !string-pointer)
  (callback-closure #:accessor !callback-closure)
  (bv-cache #:accessor !bv-cache #:init-value #f)
  (bv-cache-ptr #:accessor !bv-cache-ptr #:init-value #f)
  (is-pointer? #:accessor !is-pointer? #:init-keyword #:is-pointer?)
  (may-be-null? #:accessor !may-be-null? #:init-keyword #:may-be-null?)
  (is-caller-allocate? #:accessor !is-caller-allocate?)
  (is-optional? #:accessor !is-optional?)
  (is-return-value? #:accessor !is-return-value?)
  (is-skip? #:accessor !is-skip?)
  (arg-pos #:accessor !arg-pos #:init-keyword #:arg-pos #:init-value -1)
  (gi-argument-in #:accessor !gi-argument-in #:init-value #f)
  (gi-argument-in-bv-pos #:accessor !gi-argument-in-bv-pos #:init-value #f)
  (gi-argument-out #:accessor !gi-argument-out #:init-value #f)
  (gi-argument-out-bv-pos #:accessor !gi-argument-out-bv-pos #:init-value #f)
  (gi-argument-field #:accessor !gi-argument-field #:init-keyword #:gi-argument-field))

(define-method (initialize (self <argument>) initargs)
  (let ((info (or (get-keyword #:info initargs #f)
                  (error "Missing #:info initarg: " initargs)))
        (is-method? (get-keyword #:is-method? initargs #f)))
    (case info
      ((instance)
       (receive (split-kw split-rest)
           (split-keyword-args (list #:info) initargs)
         (next-method self split-rest)))
      (else
       (next-method self '())
       (let* ((g-name (g-base-info-get-name info))
              (name (g-name->name g-name))
              (closure (g-arg-info-get-closure info))
              (destroy (g-arg-info-get-destroy info))
              (direction (g-arg-info-get-direction info))
              (transfer (g-arg-info-get-ownership-transfer info))
              (scope (g-arg-info-get-scope info))
              (type-info (g-arg-info-get-type info))
              (type-tag (g-type-info-get-tag type-info))
              (is-pointer? (g-type-info-is-pointer type-info))
              (may-be-null? (g-arg-info-may-be-null info))
              (is-caller-allocate? (g-arg-info-is-caller-allocates info))
              (is-optional? (g-arg-info-is-optional info))
              (is-return-value? (g-arg-info-is-return-value info))
              (is-skip? (g-arg-info-is-skip info))
              (forced-type (arg-info-forced-type direction type-tag is-pointer?)))
         (receive (type-desc sub-type-desc)
             (type-description type-info
                               #:type-tag type-tag #:is-method? is-method?)
           #;(g-base-info-unref type-info)
           (g-base-info-unref info)
           (mslot-set! self
                       'type-info type-info
                       'g-name g-name
                       'name name
                       'closure closure
                       'destroy destroy
                       'direction direction
                       'transfer transfer
                       'scope scope
                       'type-tag type-tag
                       'type-desc type-desc
                       'is-enum? (and (eq? type-tag 'interface)
                                      (match type-desc
                                        ((type name gi-type g-type)
                                         (or (eq? type 'enum)
                                             (eq? type 'flags)))))
                       'sub-type-desc sub-type-desc
                       'forced-type forced-type
                       'is-pointer? is-pointer?
                       'may-be-null? may-be-null?
                       'is-caller-allocate? is-caller-allocate?
                       'is-optional? is-optional?
                       'is-return-value? is-return-value?
                       'is-skip? is-skip?
                       ;; the gi-argument-in and gi-argument-out slots can
                       ;; only be set! at the end of
                       ;; function-arguments-and-gi-arguments, which needs
                       ;; to proccess them all before it can compute their
                       ;; respective pointer address (see
                       ;; finalize-arguments-gi-argument-pointers).
                       'gi-argument-field (gi-type-tag->field forced-type))))))))

#;(define-method* (describe (self <argument>) #:key (port #t))
  (next-method self #:port port))

(define (arg-info-forced-type direction type-tag is-pointer?)
  (if (or is-pointer?
          (eq? direction 'inout)
          (eq? direction 'out))
      'pointer
      type-tag))

(define* (type-description info #:key (type-tag #f) (is-method? #f))
  (let ((type-tag (or type-tag
                      (g-type-info-get-tag info))))
    (case type-tag
      ((interface)
       (receive (iface-type name gi-type g-type)
           (type-description-interface info)
         (values (list iface-type name gi-type g-type)
                 #f)))
      ((array)
       (receive (type-desc sub-type-desc)
           (type-description-array info is-method?)
         (values type-desc
                 sub-type-desc)))
      ((glist
        gslist)
       (values (type-description-glist info type-tag)
               #f))
      (else
       (values type-tag
               #f)))))

(define (type-description-interface info)
  (let* ((iface-info (g-type-info-get-interface info))
         (iface-type (g-base-info-get-type iface-info)))
    (case iface-type
      ((callback)
       ;; in this case, iface-info is a GICallableInfo and must not be
       ;; (g-base-info-)unref, as it's needed to prepare the callback
       ;; every time the function (method) holding this argument is
       ;; called.
       (values 'callback #f iface-info #f))
      (else
       (if (is-registered? iface-type)
           (receive (g-type name gi-type)
               (registered-type->gi-type iface-info iface-type)
             (g-base-info-unref iface-info)
             (values iface-type name gi-type g-type))
           (begin
             (g-base-info-unref iface-info)
             (values iface-type #f #f #f)))))))

(define (type-description-array info is-method?)
  (let* ((type (g-type-info-get-array-type info))
         (fixed-size (g-type-info-get-array-fixed-size info))
         (is-zero-terminated (g-type-info-is-zero-terminated info))
         (param-n (g-type-info-get-array-length info))
         (param-type (g-type-info-get-param-type info 0))
         (param-tag (g-type-info-get-tag param-type)))
    (case param-tag
      ((interface)
       (receive (iface-type name gi-type g-type)
           (type-description-interface param-type)
         (g-base-info-unref param-type)
         (values (list type
                       fixed-size
                       is-zero-terminated
                       (if is-method? (+ param-n 1) param-n)
                       param-tag)
                 (list iface-type name gi-type g-type))))
      (else
       (g-base-info-unref param-type)
       (values (list type
                     fixed-size
                     is-zero-terminated
                     ;; Unless g-type-info-get-array-length returns -1
                     ;; (fixed-sized or zero-terminated arrays), when the
                     ;; callable is a method, we must add 1 to the above call
                     ;; result because GI typelibs do not take the first method
                     ;; argument into account, added by GI lang bindings, and
                     ;; hence, for methods, GI typelibs param-n values are off
                     ;; by one.
                     (if (= param-n -1)
                         param-n
                         (if is-method? (+ param-n 1) param-n))
                     param-tag)
               (list param-tag #f #f #f))))))

(define (type-description-glist info type-tag)
  (let* ((param-type (g-type-info-get-param-type info 0))
         (param-tag (g-type-info-get-tag param-type))
         (is-pointer? (g-type-info-is-pointer param-type)))
    (case param-tag
      ((interface)
       (receive (iface-type name gi-type g-type)
           (type-description-interface param-type)
         (g-base-info-unref param-type)
         (list iface-type name gi-type g-type)))
      (else
       (g-base-info-unref param-type)
       (list param-tag
             #f
             #f
             #f)))))

(define (registered-type->gi-type info type)
  (let* ((g-type (g-registered-type-info-get-g-type info))
         (g-name (gi-registered-type-info-name info))
         (name (g-name->name g-name)))
    (case type
      ((enum)
       (values g-type
               name
               (or (gi-cache-ref 'enum name)
                   (gi-import-enum info))))
      ((flags)
       (values g-type
               name
               (or (gi-cache-ref 'flags name)
                   (gi-import-flags info))))
      ((struct)
       (values g-type
               name
               (or (gi-cache-ref 'boxed name)
                   (gi-import-struct info))))
      ((union)
       (values g-type
               name
               (or (gi-cache-ref 'boxed name)
                   (gi-import-union info))))
      ((object)
       (let* ((module (resolve-module '(g-golf hl-api gobject)))
              (c-name (g-name->class-name g-name))
              (c-inst (or (and (module-variable module c-name)
                               (module-ref module c-name))
                          ((@ (g-golf hl-api object) gi-import-object) info))))
         (values g-type
                 c-name
                 c-inst)))
      ((interface)
       (let* ((module (resolve-module '(g-golf hl-api gobject)))
              (c-name (g-name->class-name g-name))
              (c-inst (or (and (module-variable module c-name)
                               (module-ref module c-name))
                          ((@ (g-golf hl-api object) gi-import-interface) info))))
         (values g-type
                 c-name
                 c-inst)))
      (else
       (values g-type name #f)))))

(define (is-registered? type-tag)
  (memq type-tag '(enum flags interface object struct union)))


;;;
;;; Registered types
;;;

;; The gi-import-* procedures must always import the info - unlike I
;; thought when initially implementing an exception mechanism to avoid
;; to import from GLib and GObject - because they are called by
;; registered-type->gi-type, to the final aim of having any 'possible'
;; argument and returned value type being fully 'described', so 'in,
;; 'inout, 'out arguments, as well as returned value(s) may be correctly
;; encoded/decoded from/to their scheme representation.

;; So, here is a 'wip step' to achieve the above goal, but wrt to info
;; that are part of GLib and GObject, the import procs will only import
;; the info itself, not its methods (because they have been or should be
;; manually binded, see (g-golf glib) and (g-golf gobject) modules.

(define* (gi-import-enum info #:key (with-methods? #t) (force? #f))
  (gi-import-registered info
                        'enum
                        gi-enum-import
                        g-enum-info-get-n-methods
                        g-enum-info-get-method
                        #:with-methods? with-methods?
                        #:force? force?))

(define* (gi-import-flags info #:key (with-methods? #t) (force? #f))
  (gi-import-registered info
                        'flags
                        gi-enum-import
                        g-enum-info-get-n-methods
                        g-enum-info-get-method
                        #:with-methods? with-methods?
                        #:force? force?))

(define* (gi-import-struct info #:key (with-methods? #t) (force? #f))
  (gi-import-registered info
                        'struct
                        gi-struct-import
                        g-struct-info-get-n-methods
                        g-struct-info-get-method
                        #:with-methods? with-methods?
                        #:force? force?))

(define* (gi-import-union info #:key (with-methods? #t) (force? #f))
  (gi-import-registered info
                        'union
                        gi-union-import
                        g-union-info-get-n-methods
                        g-union-info-get-method
                        #:with-methods? with-methods?
                        #:force? force?)
  (when (and (string=? (g-base-info-get-namespace info) "Gdk")
             (string=? (g-base-info-get-name info) "Event")
             (string=? (g-irepository-get-version "Gdk") "3.0"))
    (let* ((import-m (resolve-module '(g-golf hl-api import)))
           (%gi-import-by-name (module-ref import-m 'gi-import-by-name))
           (events-m (resolve-module '(g-golf hl-api events)))
           (%gdk-event-class-redefine (module-ref events-m 'gdk-event-class-redefine)))
      (for-each (lambda (item)
                  (%gi-import-by-name "Gdk" item #:version "3.0"))
          '("ModifierType"
            "CrossingMode"
            "NotifyType"
            "keyval_name"))
    (%gdk-event-class-redefine)
    (gi-strip-boolean-result-add gdk-event-get-axis
                                 gdk-event-get-button
                                 gdk-event-get-click-count
                                 gdk-event-get-coords
                                 gdk-event-get-keycode
                                 gdk-event-get-keyval
                                 gdk-event-get-root-coords
                                 gdk-event-get-scroll-direction
                                 gdk-event-get-scroll-deltas
                                 gdk-event-get-state))))

(define* (gi-import-registered info
                               type
                               import-proc
                               import-n-method-proc
                               import-get-method-proc
                               #:key (with-methods? #t)
                               (force? #f))
  (let* ((namespace (g-base-info-get-namespace info))
         (g-type (g-registered-type-info-get-g-type info))
         (g-name (gi-registered-type-info-name info))
         (name (g-name->name g-name)))
    (or (gi-cache-ref type name)
        (let ((gi-type-inst (case type
                              ((flags)
                               (import-proc info #:flags #t))
                              ((union)
                               (import-union-1 info g-type g-name))
                              (else
                               (import-proc info)))))
          (gi-cache-set! (case type
                           ((struct union) 'boxed)
                           ((interface) 'iface)
                           (else type))
                         name
                         gi-type-inst)
          (when with-methods?
            (gi-import-registered-methods info
                                          import-n-method-proc
                                          import-get-method-proc
                                          #:force? force?))
          gi-type-inst))))

(define* (gi-import-registered-methods info
                                       import-n-method-proc
                                       import-get-method-proc
                                       #:key (force? #f))
  (let ((%gi-import-function
         (@ (g-golf hl-api function) gi-import-function))
        (namespace (g-base-info-get-namespace info))
        (n-method (import-n-method-proc info)))
    (do ((i 0
            (+ i 1)))
        ((= i n-method))
      (let* ((m-info (import-get-method-proc info i))
             (name (g-function-info-get-symbol m-info)))
        ;; Some methods listed here are functions: (a) their flags is an
        ;; empty list; (b) they do not expect an additional instance
        ;; argument (their GIargInfo list is complete); (c) they have a
        ;; GIFuncInfo entry in the namespace (methods do not). We do not
        ;; (re)import those here.
        (unless (g-irepository-find-by-name namespace name)
          (%gi-import-function m-info #:force? force?))))))

(define (import-union-1 info g-type name)
  (let ((fields
         (map (lambda (field)
                (match field
                  ((f-name f-type-info)
                   (let ((f-desc (type-description f-type-info)))
                     (g-base-info-unref f-type-info)
                     (list f-name f-desc)))))
           (gi-union-import info))))
    (make <gi-union>
      #:g-type g-type
      #:g-name name
      ;; #:name the initialize method does that
      #:size (g-union-info-get-size info)
      #:alignment (g-union-info-get-alignment info)
      #:fields fields
      #:is-discriminated? (g-union-info-is-discriminated? info)
      #:discriminator-offset (g-union-info-get-discriminator-offset info))))
