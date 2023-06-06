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
;; gobject gobject), see:

;;   https://www.gnu.org/software/guile-gnome

;;   http://git.savannah.gnu.org/cgit/guile-gnome.git
;;     tree/glib/gnome/gobject/gobject.scm

;;; Code:


(define-module (g-golf hl-api gobject)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf gi)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api iface)

  #:replace (connect)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<gobject-class>
            <gobject>
            gobject-class?
            <ginterface>
            ginterface-class?

            g-object-find-class-by-g-type
            g-object-find-class
            g-object-make-class
            g-interface-make-class
            gi-add-method
            gi-add-method-gf))


#;(g-export )


;;;
;;; Connect
;;;

;; This code was in (g-golf hl-api signal), but (a) all other guile core
;; or user procedure 'promotion' to gf are done using (g-golf hl-api
;; gobject), and (b) a Gio based example, iif using the 'open signal,
;; revealed that unless connect is promoted as a gf in this module
;; (which is defined and imported before signal, and of course before
;; any user import(s)), then an 'overrides core binding' warning is
;; displayed, followed by a "module-lookup"connect exception.

(define %connect
  (module-ref the-root-module 'connect))

(define-method (connect . args)
  "The core Guile implementation of the connect(2) POSIX call"
  (apply %connect args))


;;;
;;; <gobject-class>
;;;


(define-class <gobject-class> (<gtype-class>))

(define (has-slot? slots name)
  (let loop ((slots slots))
    (match slots
      (#f #f)
      (() #f)
      ((slot . rest)
       (or (eq? (slot-definition-name slot) name)
           (loop rest))))))

(define (has-valid-property-flag? g-flags)
  (let ((valid-flags '(readable writable readwrite))
        (invalid-flags '(deprecated)))
    (let loop ((g-flags g-flags))
      (if (null? g-flags)
          #f)
      (match g-flags
        ((flag . rest)
         (if (and (memq flag valid-flags)
                  (not (memq flag invalid-flags)))
             #t
             (loop rest)))))))

(define (compute-extra-slots class g-properties slots)
  (if (null? g-properties)
      '()
      (let* ((module (resolve-module '(g-golf hl-api gobject)))
             (info (!info class))
             (c-name (class-name class))
             ;; the g-class (class) slot is set by the initialize method
             ;; of <gtype-class>, the meta-class - but when the
             ;; compute-slots method is called, which itself calls this
             ;; procedure, that step hasn't been realized yet, hence the
             ;; following necessary let variable binding.
             (g-class (and info ;; info is #f for derived class(es)
                           (g-type-class info)))
             (extra-slots (filter-map
                              (lambda (g-property)
                                (let* ((g-name (g-base-info-get-name g-property))
                                       (name (g-name->name g-name)))
                                  (if (has-slot? slots name)
                                      #f
                                      (let* ((k-name (symbol->keyword name))
                                             (a-name (symbol-append '! name))
                                             (a-inst (if (module-variable module a-name)
                                                         (module-ref module a-name)
                                                         (let ((a-inst (make-accessor a-name)))
                                                           (module-g-export! module `(,a-name))
                                                           (module-set! module a-name a-inst)
                                                           a-inst)))
                                             (g-param-spec
                                              (and g-class
                                                   (g-object-class-find-property g-class g-name)))
                                             (g-type (if g-param-spec
                                                         (g-param-spec-type g-param-spec)
                                                         (gi-property-g-type g-property)))
                                             (g-flags (if g-param-spec
                                                          (g-param-spec-get-flags g-param-spec)
                                                          (g-property-info-get-flags g-property)))
                                             (slot (make <slot>
                                                     #:name name
                                                     #:g-property g-property
                                                     #:g-name g-name
                                                     #:g-param-spec g-param-spec
                                                     #:g-type g-type
                                                     #:g-flags g-flags
                                                     #:allocation #:g-property
                                                     #:accessor a-inst
                                                     #:init-keyword k-name)))
                                        slot))))
                              g-properties)))
        extra-slots)))

(define (n-prop-prop-accessors class)
  ;; Note that at this point, the g-type slot of the class is still
  ;; unbound.
  (let* ((info (!info class))
         (g-type (g-registered-type-info-get-g-type info)))
    (case (g-type->symbol g-type)
      ((object)
       (values g-object-info-get-n-properties
               g-object-info-get-property))
      ((interface)
       (values g-interface-info-get-n-properties
               g-interface-info-get-property))
      (else
       (error "Not a GObject nor an Ginterface class:" class)))))

(define (gobject-ginterface-direct-properties class)
  (match (!info class)
    ((or (? boolean?)
         (? number?)) '())
    ((? pointer?)
     (receive (get-n-properties get-property)
         (n-prop-prop-accessors class)
       (let* ((info (!info class))
              (n-prop (get-n-properties info)))
         (let loop ((i 0)
                    (result '()))
           (if (= i n-prop)
               (reverse! result)
               (loop (+ i 1)
                     (cons (get-property info i)
                           result)))))))))

(define-method (compute-slots (class <gobject-class>))
  (let* ((slots (next-method))
         (extra (compute-extra-slots class
                                     (gobject-ginterface-direct-properties class)
                                     slots)))
    (slot-set! class 'direct-slots
               (append (slot-ref class 'direct-slots)
                       extra))
    (append slots extra)))

(define* (is-readable? slot #:optional (slot-opts #f))
  (let* ((slot-opts (or slot-opts
                        (slot-definition-options slot)))
         (g-flags (get-keyword #:g-flags slot-opts #f)))
    (and g-flags
         (memq 'readable g-flags))))

(define* (is-writable? slot #:optional (slot-opts #f))
  (let* ((slot-opts (or slot-opts
                        (slot-definition-options slot)))
         (g-flags (get-keyword #:g-flags slot-opts #f)))
    (and g-flags
         (memq 'writable g-flags)
         (not (memq 'construct-only g-flags)))))

(define-method (compute-get-n-set (class <gobject-class>) slot-def)
  (case (slot-definition-allocation slot-def)
    ((#:g-property)
     (let* ((name (slot-definition-name slot-def))
            (slot-opts (slot-definition-options slot-def))
            (g-name (get-keyword #:g-name slot-opts #f))
            (g-type (get-keyword #:g-type slot-opts #f)))
       (list (lambda (obj)
               #;(if (is-readable? slot-def slot-opts)
                   (g-inst-get-property (!g-inst obj) g-name g-type)
                   (error "Unreadable slot:" name))
               (g-inst-get-property (!g-inst obj) g-name g-type))
             (lambda (obj val)
               #;(if (is-writable? slot-def slot-opts)
                   (g-inst-set-property (!g-inst obj) g-name g-type val)
                   (error "Unwritable slot:" name))
               (g-inst-set-property (!g-inst obj) g-name g-type val)))))
    (else
     (next-method))))

(define-method (initialize (class <gobject-class>) initargs)
  (let ((info (get-keyword #:info initargs #f))
        (g-type (get-keyword #:g-type initargs #f)))
    (next-method
     class
     (cond (info initargs)
           (g-type (cons* #:info g-type initargs))
           (else
            (receive (g-type class-init-func instance-init-func)
                (g-golf-type-register class initargs)
              (when class-init-func
                (mslot-set! class
                            'class-init-func class-init-func
                            'instance-init-func instance-init-func))
              (cons* #:derived #t
                     #:info g-type
                     initargs)))))))

(define %class-init-func
  (lambda (name template child-ids)
    (let* ((module (resolve-module '(g-golf hl-api function)))
           (set-template (module-ref module 'gtk-widget-class-set-template))
           (bind-template-child-full
            (module-ref module 'gtk-widget-class-bind-template-child-full))
           (template-bv (call-with-input-file template
                         (lambda (port) (get-bytevector-all port)) #:binary #t))
           (g-bytes (g-bytes-new (bytevector->pointer template-bv)
                                 (bytevector-length template-bv))))
      (procedure->pointer void
                          (lambda (g-class class-data)
                            (let ((%name name)
                                  (%g-bytes g-bytes)
                                  (%child-ids child-ids))
                              #;(dimfi '%class-init-func %name)
                              #;(dimfi "  " 'g-class g-class 'child-ids %child-ids)
                              (set-template g-class %g-bytes)
                              (for-each (lambda (child-id)
                                          (bind-template-child-full g-class
                                                                    child-id
                                                                    #f
                                                                    0))
                                  %child-ids)
                              (values)))
                          (list '* '*)))))

(define %instance-init-func
  (lambda (c-name)
    (let* ((init-template-func (gi-cache-ref 'function 'gtk-widget-init-template))
           (gi-argument (slot-ref init-template-func 'gi-args-in))
           (init-template (slot-ref init-template-func 'i-func)))
      (procedure->pointer void
                          (lambda (g-inst g-class)
                            (let* ((%c-name c-name)
                                   (class (g-class-cache-ref g-class))
                                   (g-type (!g-type class)))
                              (gi-argument-set! gi-argument 'v-pointer g-inst)
                              (apply init-template
                                     (list g-inst 'skip-prepare-gi-arguments))
                              #;(dimfi '%instance-init-func (class-name class))
                              #;(dimfi "  " 'closure-name %c-name 'g-type (!g-type class))
                              #;(dimfi "  " 'g-inst-construct-g-type (%g-inst-construct-g-type))
                              (let ((g-inst-construct-g-type (%g-inst-construct-g-type)))
                                (unless (and g-inst-construct-g-type
                                             (= g-type g-inst-construct-g-type))
                                  (make class #:g-inst g-inst)))
                              (values)))
                          (list '* '*)))))

(define (is-a-gtk-widget? dsupers)
  (member '<gtk-widget>
          (map class-name
            (apply append (map class-precedence-list
                            dsupers)))))

(define (g-golf-type-register class initargs)
  (let* ((name (get-keyword #:name initargs #f))
         (g-name (class-name->g-name name))
         (dsupers (get-keyword #:dsupers initargs '()))
         (p-type (!g-type (find gobject-class?
                                (apply append
                                       (map class-precedence-list dsupers)))))
         (template (get-keyword #:template initargs #f))
         (child-ids (get-keyword #:child-ids initargs '())))
    (if (and template
             (not (is-a-gtk-widget? dsupers)))
        (scm-error 'invalid-class #f
                   "Invalid (template) class: ~A"
                   (list name) #f)
        (match (g-type-query p-type)
          ((p-type p-name class-size instance-size)
           (let* ((class-init-func (and template
                                        (%class-init-func name template child-ids)))
                  (instance-init-func (and template
                                           (%instance-init-func name)))
                  (g-type (g-type-register-static-simple p-type
                                                        g-name
                                                        class-size
                                                        class-init-func
                                                        instance-size
                                                        instance-init-func
                                                        '())))
             (for-each (lambda (iface-class)
                         (g-golf-type-add-interface g-type iface-class))
                 (filter-map (lambda (class)
                               (and (ginterface-class? class) class))
                     dsupers))
             (values g-type
                     class-init-func
                     instance-init-func)))))))

(define (g-golf-type-add-interface g-type iface-class)
  (g-type-add-interface-static g-type
                               (!g-type iface-class)
                               (gi-iface-info-struct iface-class)))

(define (g-inst-get-property inst g-name g-type)
  (let* ((g-value (g-value-init g-type))
         (dummy (g-object-get-property inst g-name g-value))
         (result (%g-inst-get-property-value g-value)))
    (g-value-unset g-value)
    result))

(define (%g-inst-get-property-value g-value)
  (let ((value (g-value-ref g-value)))
    (case (g-value-type-tag g-value)
      ((object)
       (if (or (not value)
               (null-pointer? value))
           #f
           (or (g-inst-cache-ref value)
               (let* ((module (resolve-module '(g-golf hl-api gobject)))
                      (r-type (g-value-type g-value))
                      (info (g-irepository-find-by-gtype r-type))
                      (g-name (g-registered-type-info-get-type-name info))
                      (c-name (g-name->class-name g-name))
                      (type (module-ref module c-name)))
                 (make type #:g-inst value)))))
      ((interface)
       (if (or (not value)
               (null-pointer? value))
           #f
           (or (g-inst-cache-ref value)
               (let* ((module (resolve-module '(g-golf hl-api gobject)))
                      (r-type (g-value-type g-value))
                      (info (g-irepository-find-by-gtype r-type))
                      (g-name (g-registered-type-info-get-type-name info))
                      (c-name (g-name->class-name g-name))
                      (type (module-ref module c-name)))
                 (make type #:g-inst value)))))
      (else
       value))))

(define* (g-inst-set-property inst g-name g-type value)
  (let ((g-value (g-value-init g-type)))
    (g-value-set! g-value
                  (%g-inst-set-property-value g-type value))
    (g-object-set-property inst g-name g-value)
    (g-value-unset g-value)
    (values)))

(define %g-inst-set-property-value
  (@@ (g-golf hl-api gtype) %g-inst-set-property-value))


;;;
;;; Signals
;;;

(define (install-signals! class)
  (let ((signals (gobject-class-signals class)))
    (dimfi class)
    (for-each (lambda (info)
                (dimfi "  " (g-base-info-get-name info)))
        signals)))

(define (gobject-class-signals class)
  (if (boolean? (!info class))
      '()
      (let* ((info (!info class))
             (n-signal (g-object-info-get-n-signals info)))
        (let loop ((i 0)
                   (result '()))
          (if (= i n-signal)
              (reverse! result)
              (loop (+ i 1)
                    (cons (g-object-info-get-signal info i)
                          result)))))))


;;;
;;; <gobject>
;;;

(eval-when (expand load eval)
  (g-irepository-require "GObject"))

(define-class <gobject> (<gtype-instance>)
  #:info (g-irepository-find-by-name "GObject" "Object")
  #:metaclass <gobject-class>)

(define safe-class-name
  (@@ (oop goops describe) safe-class-name))

(define-method (describe (x <gobject>))
  (format #t "~S is an instance of class ~A~%"
	  x
          (safe-class-name (class-of x)))
  (format #t "Slots are: ~%")
  (for-each (lambda (slot)
	      (let ((name (slot-definition-name slot))
                    (slot-opts (slot-definition-options slot)))
                (case (slot-definition-allocation slot)
                  ((#:g-property)
                   (if (is-readable? slot slot-opts)
                       (format #t "     ~S = ~A~%"
			       name
			       (if (slot-bound? x name)
			           (format #f "~S" (slot-ref x name))
			           "#<unbound>"))
                       (format #t "     ~S = n/a [the slot is ~S only]~%"
			       name
                               (get-keyword #:g-flags slot-opts #f))))
                  (else
		   (format #t "     ~S = ~A~%"
			   name
			   (if (slot-bound? x name)
			       (format #f "~S" (slot-ref x name))
			       "#<unbound>"))))))
	    (class-slots (class-of x)))
  *unspecified*)

(define (gobject-class? val)
  ;; For the record, Guile-Gnome also defines the same procedure, but in
  ;; Guile-Gnome, it is guaranteed to always receive a class as its
  ;; argument (called c).  Here in G-Golf, gobject-class? is/must be
  ;; called in context that val is a type tag, not a class.
  (and (is-a? val <class>)
       (memq <gobject>
             (class-precedence-list val))
       #t))


;;;
;;; <ginterface>
;;;

#;(define-class <ginterface-class> (<gtype-class>))

(define-class <ginterface> (<gtype-instance>)
  #:info #t
  #:g-type -1	;; g-object-find-class-by-g-type
  #:metaclass <gobject-class>)

(define (ginterface-class? class)
  (let ((cpl (class-precedence-list class)))
    (and (not (memq <gobject> cpl))
         (memq <ginterface> cpl)
         #t)))


;;;
;;; Utils
;;;

;; Below, procedures and methods to support the (g-golf hl-api function)
;; module, wrt its goops/gobject 'required' functionality.

;; [1]

;; Used by gi-argument->scm to either retrieve or create (sub)classes,
;; when that is necessary, that (a) are not defined in the (their
;; parent) namespace and (b) may differ from one call to another.

;; For example, a call to webkit-web-view-get-tls-info may return, for
;; it second 'out argument, a <g-tls-certificate-gnutls> instance, but
;; (a) "GTlsCertificateGnutls" is a runtime class - that is, undefined
;; in its corresponding namespace - subclass of "GTlsCertificate" and
;; (b) a subsequent call to webkit-web-view-get-tls-info could very well
;; return another certificate subclass type.

;; Another example of a runtime class is the GdkWaylandClipboard, which
;; subclass GdkClipboard.

(define (g-object-find-class-by-g-type g-type)
  (let loop ((classes (class-subclasses <gtype-instance>)))
    (match classes
      (() #f)
      ((head . tail)
       (if (= (!g-type head) g-type)
           head
           (loop tail))))))

(define (g-object-find-class foreign)
  (let* ((g-type (g-object-type foreign))
         (class (g-object-find-class-by-g-type g-type)))
    (if class
        (values class (class-name class) g-type)
        (g-object-make-class foreign g-type))))

(define* (g-object-make-class foreign #:optional g-type)
  (let* ((module (resolve-module '(g-golf hl-api gobject)))
         (g-type (or g-type (g-object-type foreign)))
         (g-name (g-object-type-name foreign))
         (c-name (g-name->class-name g-name))
         (parent (g-type-parent g-type))
         (p-g-name (g-type-name parent))
         (p-name (g-name->class-name p-g-name))
         (p-class-var (module-variable module p-name))
         (p-class (and p-class-var (module-ref module p-name))))
    (when (%debug)
      (dimfi 'g-object-make-class)
      (dimfi "  " g-type g-name c-name 'p-name p-name))
    (if p-class
        (let* ((public-i (module-public-interface module))
               (ifaces (g-object-class-interfaces g-type))
               (c-inst (make-class (cons p-class ifaces)
                                   '()
                                   #:name c-name
                                   #:g-type g-type)))
          (module-define! module c-name c-inst)
          (module-add! public-i c-name
                       (module-variable module c-name))
          (values c-inst c-name g-type))
        (error "Undefined (parent) class: " p-name))))

(define (g-object-class-interfaces g-type)
  (let ((module (resolve-module '(g-golf hl-api gobject)))
        (ifaces (g-type-interfaces g-type)))
    (map (lambda (iface)
           (let* ((g-name (g-type-name iface))
                  (name (g-name->class-name g-name))
                  (m-var (module-variable module name)))
             (or (and m-var
                      (variable-ref m-var))
                 (g-interface-make-class g-type))))
      ifaces)))

(define (g-interface-make-class g-type)
  (let* ((module (resolve-module '(g-golf hl-api gobject)))
         (public-i (module-public-interface module))
         (g-name (or (g-type-name g-type)	 ;; we use 0 as a g-type
                     "AGInterfaceRuntimeClass")) ;; to test/debug
         (c-name (g-name->class-name g-name))
         (c-inst (make-class `(,<ginterface>)
                             '()
                             #:name c-name
                             #:g-type g-type)))
    (module-define! module c-name c-inst)
    (module-add! public-i c-name
                 (module-variable module c-name))
    c-inst))

(define (gi-add-method generic specializers procedure)
  (for-each (lambda (xp-spec)
              (add-method! generic
                           (make <method>
                             #:specializers xp-spec
                             #:procedure procedure)))
      (explode specializers)))

#!

The gi-add-method-gf code now uses ensure-generic, when its name
argument is find to be bound to a procedure. It should have used it in
the first place, but I've looked at the code and ensure-generic actually
does a better job then what I wrote, because it checks if the procedure
is a procedure-with-setter?, and returns a <generic-with-setter>
instance, otherwise, it returns a <generic> instance.

Nonetheless, I'll keep the code I wrote as an example of 'manually'
promoting a procedure (with no setter) to a generic function, adding a
method with its 'old' definition.

  ...
  (else
   (module-replace! module `(,name))
   (let ((gf (make <generic> #:name name)))
     (module-set! module name gf)
     (add-method! gf
                  (make <method>
                    #:specializers <top>
                    #:procedure (lambda ( . args)
                                  (apply value args))))
     gf))

!#

(define* (gi-add-method-gf name #:optional (module #f))
  (let* ((g-golf (resolve-module '(g-golf)))
         (module (or module
                     (resolve-module '(g-golf hl-api gobject))))
         (variable (module-variable module name))
         (value (and variable
                     (variable-bound? variable)
                     (variable-ref variable)))
         (names `(,name)))
    (if value
        (cond ((generic? value)
               value)
              ((macro? value)
               (gi-add-method-gf (syntax-name->method-name name)
                                 module))
              (else
               (module-replace! module names)
               (re-export-and-replace-names! g-golf names)
               (let ((gf (ensure-generic value name)))
                 (module-set! module name gf)
                 gf)))
        (begin
          (module-export! module names)
          (let ((gf (make <generic> #:name name)))
            (module-set! module name gf)
            gf)))))
