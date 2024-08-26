;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2022 - 2023
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


(define-module (g-golf hl-api vfunc)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf gi)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api argument)
  #:use-module (g-golf hl-api ccc)
  #:use-module (g-golf hl-api callable)
  #:use-module (g-golf hl-api callback)
  #:use-module (g-golf hl-api function)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<vfunc>
            define-vfunc
            vfunc))


(g-export !specializer
          !name
          !g-name
          !long-name-prefix
          !gf-long-name?
          !info
          !callback)


(define-class <vfunc> (<method>)
  (specializer #:accessor !specializer)
  (name #:accessor !name)
  (g-name #:accessor !g-name)
  (long-name-prefix #:accessor !long-name-prefix)
  (gf-long-name? #:accessor !gf-long-name?)
  (info #:accessor !info)
  (callback #:accessor !callback))

(define-method (describe (self <vfunc>))
  (next-method)
  (format #t "    Direct slots are: ~%")
  (for-each (lambda (slot)
	      (let ((name (slot-definition-name slot)))
		(format #t "      ~S = ~A~%"
			name
			(if (slot-bound? self name) 
			    (format #f "~S" (slot-ref self name))
			    "#<unbound>"))))
      (class-direct-slots (class-of self)))
  #;(format #t "    Method slots are: ~%")
  #;(for-each (lambda (slot)
	      (let ((name (slot-definition-name slot)))
		(format #t "      ~S = ~A~%"
			name
			(if (slot-bound? self name)
			    (format #f "~S" (slot-ref self name))
			    "#<unbound>"))))
      (class-direct-slots <method>))
  *unspecified*)

(define-syntax define-vfunc
  (syntax-rules ()
    ((_ (vf-name . args) body ...)
     (let ((vf (vfunc 'vf-name args body ...)))
       (receive (specializer g-name g-long-name-prefix gf-long-name? info)
           (vfunc-checks 'vf-name (slot-ref vf 'specializers))
         (mslot-set! vf
                     'specializer specializer
                     'name (g-name->name g-name)
                     'g-name (string->symbol g-name)
                     'long-name-prefix (g-name->name g-long-name-prefix)
                     'gf-long-name? gf-long-name?
                     'info info)
         (add-method! (gi-add-method-gf 'vf-name) vf)
         (add-vfunc-closure vf))))))

(define (add-vfunc-closure vf)
  (receive (closure callback-closure)
      (g-golf-vfunc-closure vf)
    (let* ((vfunc-g-object-class-specializer
            (find-vfunc-g-object-class-specializer vf))
           (specializer (!specializer vf))
           (iface/class-struct (if (ginterface-class? specializer)
                                   (g-type-interface-peek
                                    (!g-class vfunc-g-object-class-specializer)
                                    (!g-type specializer))
                                   (g-type-class-peek
                                    (!g-type vfunc-g-object-class-specializer)))))
      (slot-set! vf
                 'callback (!callback callback-closure))
      (match (vfunc-struct-field vf)
        ((type-tag offset flags)
         (bv-ptr-set! (gi-pointer-inc iface/class-struct offset)
                      closure))))))

(define (find-vfunc-g-object-class-specializer vf)
  ;; There can only be one GObject class - as GObject is a single
  ;; inheritance oop system - in the list of the <vfunc> vf
  ;; specializers.
  (or (find gobject-class? (slot-ref vf 'specializers))
      (scm-error 'impossible #f "No GObject specializer for: ~S"
                 (list (!name vf)) #f)))

(define (vfunc-struct-field vf)
  (assq-ref (!g-struct-fields (!specializer vf))
            (!name vf)))

(define (g-golf-vfunc-closure vf)
  (let* ((name (symbol-append (!long-name-prefix vf)
                              '-
                              (!name vf)))
         (info (!info vf))
         (proc (slot-ref vf 'procedure))
         (callback (gi-import-vfunc name info))
         (callback-closure (make <callback-closure>
                             #:callback callback
                             #:procedure proc)))
    (values (g-callable-info-make-closure info
                                          (!ffi-cif callback)
                                          %g-golf-callback-closure-marshal
                                          (scm->pointer callback-closure))
            callback-closure)))

;; We need to cache Vfunc callbacks against their VFunc long name, which we
;; could build using the info. However, as a VFunc is only imported 'on
;; demand', when gi-import-vfunc is called the <vfunc> instance has already
;; been made, and it has the long name we need to either cache-ref or
;; cache-set!.

(define (gi-import-vfunc name info)
  (let ((namespace (g-base-info-get-namespace info)))
    (when (%debug)
      (dimfi 'import-vfunc namespace name))
    (or (gi-callback-inst-cache-ref name)
        (let ((callback (make <callback> #:info info)))
          ;; Do not (g-base-info-)unref the callback info - it is
          ;; required when invoked.
          (gi-callback-inst-cache-set! name callback)
          callback))))

(define %mandatory-long-name-error-msg
  "More then one specializer defines a VFunc (method) for NAME: ~S. In these
situations a VFunc (method) long name is mandatory and ~S is invalid.")

(define (vfunc-checks vf-name specializers)
  (let ((str-name (symbol->string vf-name)))
    (case (string-suffix-length str-name "-vfunc")
      ((6)
       (let* ((name (string-drop-right str-name 6))
              (g-name (name->g-name name 'as-string))
              (results (specializers-vfunc-lookup specializers g-name)))
         (match results
           (()
            (scm-error 'wrong-type-arg #f "No such VFunc : ~S"
                       (list name) #f))
           (((specializer g-name g-long-name-prefix gf-long-name? info))
            (values specializer
                    g-name
                    g-long-name-prefix
                    gf-long-name?
                    info))
           (((specializer g-name g-long-name-prefix gf-long-name? info) . rest)
            ;; Then there is more then one specializer that defines a VFunc
            ;; for G-NAME. In this case, we filter the results to keep, if
            ;; any, the only one result that would have its gf-long-name?
            ;; #t. Otherwise, it means that VF-NAME is a VFunc short name,
            ;; which in this situation is invalid, or VF-NAME is an invalid
            ;; long name (as a typo in the long name prefix) an exception is
            ;; raised.
            (let ((the-result (vfunc-checks-filter results)))
              (match the-result
                (#f
                 (scm-error 'wrong-type-arg #f %mandatory-long-name-error-msg
                            (list results vf-name) #f))
                ((specializer g-name g-long-name-prefix gf-long-name? info)
                 (values specializer
                         g-name
                         g-long-name-prefix
                         gf-long-name?
                         info))))))))
      (else
       (scm-error 'wrong-type-arg #f "Invalid vfunc name: ~S"
                  (list vf-name) #f)))))

(define (vfunc-checks-filter results)
  (let loop ((results results))
    (match results
      (() #f)
      ((result . rest)
       (match result
         ((specializer g-name g-long-name-prefix gf-long-name? info)
          (if gf-long-name?
              result
              (loop rest))))))))

(define (specializers-vfunc-lookup specializers g-name)
  (let loop ((specializers specializers)
             (results '()))
    (match specializers
      (() results)
      ((specializer . rest)
       (loop rest
             (append results
                     (specializer-vfunc-lookup specializer g-name)))))))

(define (specializer-vfunc-lookup specializer g-name)
  (let loop ((cpl (class-precedence-list specializer))
             (results '()))
    (match cpl
      (() (reverse results))
      ((super . rest)
       (let ((vf-info (vfunc-info-lookup super g-name)))
         (if vf-info
             (receive (g-name g-long-name-prefix gf-long-name?)
                 (vfunc-names super g-name)
               (loop rest
                     (cons (list super
                                 g-name
                                 g-long-name-prefix
                                 gf-long-name?
                                 vf-info)
                           results)))
             (loop rest results)))))))

(define (vfunc-names class g-name)
  (let* ((name (g-name->name (!g-name class) 'as-string))
         (g-long-name-prefix (name->g-name name 'as-string))
         (gf-long-name? (and (string-contains g-name
                                              g-long-name-prefix)
                             #t))
         (g-name (if gf-long-name?
                     (string-drop g-name
                                  (+ (string-length g-long-name-prefix) 1))
                     g-name)))
    (values g-name g-long-name-prefix gf-long-name?)))

(define (vfunc-info-lookup class g-name)
  (let ((find-vfunc-proc (cond ((gobject-class? class)
                                g-object-info-find-vfunc)
                               ((ginterface-class? class)
                                g-interface-info-find-vfunc)
                               (else
                                #f))))
    (and find-vfunc-proc
         ;; derived class info slot value is #f
         (let ((info (!info class)))
           (match info
             ((? pointer?)
              (find-vfunc-proc info g-name))
             (else
              #f))))))


;; Below is a modified version of the (define-syntax method ...) code in
;; (oop goops) - from which the vfunc syntax-case below is largely
;; inspired.

(define %next-vfunc
  (lambda args
    (match args
      ((vf-name . rest)
       (receive (vf specializer s-class)
           (find-vf vf-name rest)
         (receive (p-class offset)
             (vfunc-ptr-offset-lookup vf s-class)
           #;(dimfi 'next-vfunc (!name vf) offset)
           (let* ((g-class (!g-class p-class))
                  (bv-ptr (gi-pointer-inc g-class offset))
                  (vfunc-ptr (bv-ptr-ref bv-ptr)))
             (unless (null-pointer? vfunc-ptr)
               (apply (%next-vfunc-proc (!callback vf) vfunc-ptr)
                      rest)))))))))

(define (vfunc-ptr-offset-lookup vf s-class)
  (let ((name (!name vf))
        (p-class (find gobject-class?
                       (class-direct-supers s-class))))
    (values p-class
            (vfunc-ptr-offset-lookup-1 name p-class))))

(define (g-object-p-class class)
  (find gobject-class?
        (class-direct-supers class)))

(define (vfunc-ptr-offset-lookup-1 name class)
  (let loop ((class class))
    (match (!g-struct-fields class)
      (#f
       (loop (g-object-p-class class)))
      (g-struct-fields
       (match (assq-ref g-struct-fields name)
         (#f
          (loop (g-object-p-class class)))
         ((type-tag offset flags)
          offset))))))

(define (find-vf vf-name args)
  (letrec* ((module (resolve-module '(g-golf hl-api gobject)))
            (gf (module-ref module vf-name))
            (specializer (find (lambda (arg)
                                 (and (gobject-class? (class-of arg))
                                      arg))
                               args))
            (s-class (class-of specializer))
            (vf-pred (lambda (vf)
                       (memq s-class (slot-ref vf 'specializers)))))
    (values (find vf-pred (generic-function-methods gf))
            specializer
            s-class)))

(define (%next-vfunc-proc callback function)
  (lambda args
    (let ((callback callback)
          (info (!info callback))
          (name (!name callback))
          (return-type (!return-type callback))
          (n-gi-arg-in (!n-gi-arg-in callback))
          (gi-args-in (!gi-args-in callback))
          (n-gi-arg-out (!n-gi-arg-out callback))
          (gi-args-out (!gi-args-out callback))
          (gi-arg-result (!gi-arg-result callback)))
      #;(dimfi '%next-vfunc-proc)
      #;(dimfi "  " return-type n-gi-arg-in n-gi-arg-out)
      (callable-prepare-gi-arguments callback args)
      (with-gerror g-error
        (g-callable-info-invoke info
                                function
                                gi-args-in
                                n-gi-arg-in
			        gi-args-out
                                n-gi-arg-out
			        gi-arg-result
                                (!is-method? callback)
                                (!can-throw-gerror callback)
                                g-error))
      #;(dimfi "  " 'after-g-callable-info-invoke)
      (if (> n-gi-arg-out 0)
          (case return-type
            ((boolean)
             (if (gi-strip-boolean-result? name)
                 (if (callable-return-value->scm callback)
                     (apply values
                            (map callable-arg-out->scm (!args-out callback)))
                     (error " " name " failed."))
                 (apply values
                        (cons (callable-return-value->scm callback)
                              (map callable-arg-out->scm (!args-out callback))))))
            ((void)
             (apply values
                    (map callable-arg-out->scm (!args-out callback))))
            (else
             (let ((args-out (map callable-arg-out->scm (!args-out callback))))
               (apply values
                      (cons (callable-return-value->scm callback #:args-out args-out)
                            args-out)))))
          (case return-type
            ((void) (values))
            (else
             (callable-return-value->scm callback)))))))


(define-syntax vfunc
  (lambda (x)

    (define (parse-args args)
      (let lp ((ls args) (formals '()) (specializers '()))
        (syntax-case ls ()
          (((f s) . rest)
           (and (identifier? #'f) (identifier? #'s))
           (lp #'rest
               (cons #'f formals)
               (cons #'s specializers)))
          ((f . rest)
           (identifier? #'f)
           (lp #'rest
               (cons #'f formals)
               (cons #'<top> specializers)))
          (()
           (list (reverse formals)
                 (reverse (cons #''() specializers))))
          (tail
           (identifier? #'tail)
           (list (append (reverse formals) #'tail)
                 (reverse (cons #'<top> specializers)))))))

    (define (find-free-id exp referent)
      (syntax-case exp ()
        ((x . y)
         (or (find-free-id #'x referent)
             (find-free-id #'y referent)))
        (x
         (identifier? #'x)
         (let ((id (datum->syntax #'x referent)))
           (and (free-identifier=? #'x id) id)))
        (_ #f)))

    (define (compute-procedure formals body)
      (syntax-case body ()
        ((body0 ...)
         (with-syntax ((formals formals))
           #'(lambda formals body0 ...)))))

    (define (->proper args)
      (let lp ((ls args) (out '()))
        (syntax-case ls ()
          ((x . xs)        (lp #'xs (cons #'x out)))
          (()              (reverse out))
          (tail            (reverse (cons #'tail out))))))

    #;(define (compute-make-procedure formals body next-method)
      (syntax-case body ()
        ((body ...)
         (with-syntax ((next-method next-method))
           (syntax-case formals ()
             ((formal ...)
              #'(lambda (real-next-method)
                  (lambda (formal ...)
                    (let ((next-method (lambda args
                                         (dimfi 'next-method args)
                                         (if (null? args)
                                             (real-next-method formal ...)
                                             (apply real-next-method args)))))
                      body ...))))
             (formals
              (with-syntax (((formal ...) (->proper #'formals)))
                #'(lambda (real-next-method)
                    (lambda formals
                      (let ((next-method (lambda args
                                           (dimfi 'next-method args)
                                           (if (null? args)
                                               (apply real-next-method formal ...)
                                               (apply real-next-method args)))))
                        body ...))))))))))

    #;(define (compute-procedures formals body)
      ;; So, our use of this is broken, because it operates on the
      ;; pre-expansion source code. It's equivalent to just searching
      ;; for referent in the datums. Ah well.
      (let ((id (find-free-id body 'next-method)))
        (if id
            ;; return a make-procedure
            (values #'#f
                    (compute-make-procedure formals body id))
            (values (compute-procedure formals body)
                    #'#f))))

    (define (compute-procedure-with-next-vfunc vf-name formals body next-vfunc)
      (syntax-case body ()
        ((body0 ...)
         (with-syntax ((vf-name vf-name)
                       (next-vfunc next-vfunc))
           (syntax-case formals ()
             ((formal ...)
              #'(lambda (formal ...)
                  (let ((next-vfunc (lambda args
                                      (if (null? args)
                                          (%next-vfunc vf-name formal ...)
                                          (apply %next-vfunc (cons vf-name args))))))
                    body0 ...)))
             (formals
              (with-syntax (((formal ...) (->proper #'formals)))
                #'(lambda formals
                    (let ((next-vfunc (lambda args
                                        (if (null? args)
                                            (apply %next-vfunc vf-name formal ...)
                                            (apply %next-vfunc (cons vf-name args))))))
                      body0 ...)))))))))

    (define (compute-procedures vf-name formals body)
      ;; In this version, we always return #f as the second value, which
      ;; is the make-procedure in the next-method version.
      (let ((id (find-free-id body 'next-vfunc)))
        (if id
            (values (compute-procedure-with-next-vfunc vf-name formals body id)
                    #'#f)
            (values (compute-procedure formals body)
                    #'#f))))

    (syntax-case x ()
      ((_ vf-name args) #'(vfunc vf-name args (if #f #f)))
      ((_ vf-name args body0 body1 ...)
       (with-syntax (((formals (specializer ...)) (parse-args #'args)))
         (receive (procedure make-procedure)
             (compute-procedures #'vf-name #'formals #'(body0 body1 ...))
           (with-syntax ((procedure procedure)
                         (make-procedure make-procedure))
             #'(make <vfunc>
                 #:specializers (cons* specializer ...)
                 #:formals 'formals
                 #:body '(body0 body1 ...)
                 #:make-procedure make-procedure
                 #:procedure procedure))))))))
