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


(define-module (g-golf hl-api vfunc)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf gi)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api argument)
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


(g-export !vf-class
          !vf-name
          !vf-info
          !vf-long-name-prefix
          !vf-long-name?)


(define-class <vfunc> (<method>)
  (vf-class #:accessor !vf-class)
  (vf-name #:accessor !vf-name)
  (vf-info #:accessor !vf-info)
  (vf-long-name-prefix #:accessor !vf-long-name-prefix)
  (vf-long-name? #:accessor !vf-long-name?))

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
  *unspecified*)

(define-syntax define-vfunc
  (syntax-rules ()
    ((_ (name . args) body ...)
     (let ((vf-inst (vfunc args body ...)))
       (receive (vf-class vf-name vf-info vf-long-name-prefix vf-long-name?)
           (vfunc-checks 'name vf-inst)
         (let ((vfunc-gf (gi-add-method-gf 'name)))
           (add-method! vfunc-gf vf-inst)
           (mslot-set! vf-inst
                       'vf-class vf-class
                       'vf-name vf-name
                       'vf-info vf-info
                       'vf-long-name-prefix vf-long-name-prefix
                       'vf-long-name? vf-long-name?)))))))

(define %mandatory-long-name-error-msg
  "More then one specializer defines a VFunc (method) for NAME: ~S. In these
situations a VFunc (method) long name is mandatory and ~S is invalid.")

(define (vfunc-checks name vf-inst)
  (let ((str-name (symbol->string name)))
    (case (string-suffix-length str-name "-vfunc")
      ((6)
       (let* ((name (string-drop-right str-name 6))
              (g-name (name->g-name name 'as-string))
              (results (specializers-vfunc-lookup vf-inst g-name)))
         (match results
           (()
            (scm-error 'wrong-type-arg #f "No such VFunc : ~S"
                       (list name) #f))
           ;; Below, vf-name / vf-long-name-prefix are both a g-name that is,
           ;; i.e. get_flags / gdk_paintable [as opposed to get-flags /
           ;; gdk-paintable ...].
           (((vf-class vf-name vf-info vf-long-name-prefix vf-long-name?))
            (values vf-class
                    (string->symbol vf-name)
                    vf-info
                    (string->symbol vf-long-name-prefix)
                    vf-long-name?))
           (((vf-class vf-name vf-info vf-long-name-prefix vf-long-name?) . rest)
            ;; Then there is more then one specializer that defines a VFunc
            ;; for NAME. In this case, we filter the results to keep, if any,
            ;; the only one result that would have its vf-long-name?
            ;; #t. Otherwise, it means that NAME is a VFunc short name, which
            ;; in this situation is invalid, or NAME is an invalid long name
            ;; (as a typo in the long name prefix) an exception is raised.
            (let ((the-result (vfunc-checks-filter results)))
              (match the-result
                (#f
                 (scm-error 'wrong-type-arg #f %mandatory-long-name-error-msg
                            (list results vf-name) #f))
                ((vf-class vf-name vf-info vf-long-name-prefix vf-long-name?)
                 (values vf-class
                         (string->symbol vf-name)
                         vf-info
                         (string->symbol vf-long-name-prefix)
                         vf-long-name?))))))))
      (else
       (scm-error 'wrong-type-arg #f "Invalid vfunc name: ~S"
                  (list name) #f)))))

(define (vfunc-checks-filter results)
  (let loop ((results results))
    (match results
      (() #f)
      ((result . rest)
       (match result
         ((vf-class vf-name vf-info vf-long-name-prefix vf-long-name?)
          (if vf-long-name?
              result
              (loop rest))))))))

(define (specializers-vfunc-lookup vf-inst g-name)
  (let loop ((specializers (slot-ref vf-inst 'specializers))
             (results '()))
    (match specializers
      (() results)
      ((specializer . rest)
       (loop rest
             (append results
                     (specializer-vfunc-lookup specializer g-name)))))))

(define (specializer-vfunc-lookup specializer g-name)
  (let loop ((supers (class-direct-supers specializer))
             (results '()))
    (match supers
      (() (reverse results))
      ((super . rest)
       (let* ((vf-long-name-prefix
               (name->g-name (g-name->name (!g-name super) 'as-string) 'as-string))
              (vf-long-name?
               (and (string-contains g-name vf-long-name-prefix) #t))
              (vf-name (if vf-long-name?
                           (string-drop g-name
                                        (+ (string-length vf-long-name-prefix) 1))
                           g-name))
              (g-vfunc-lookup (cond ((gobject-class? super)
                                     g-object-vfunc-lookup)
                                    ((ginterface-class? super)
                                     g-interface-vfunc-lookup)
                                    (else
                                     #f))))
         (if g-vfunc-lookup
             (let ((vf-info (g-vfunc-lookup super vf-name)))
               (if vf-info
                   (loop rest
                         (cons (list super
                                     vf-name
                                     vf-info
                                     vf-long-name-prefix
                                     vf-long-name?)
                               results))
                   (loop rest results)))
             (loop rest results)))))))

(define (g-object-vfunc-lookup c-lass g-name)
  (g-object-info-find-vfunc (!info c-lass) g-name))

(define (g-interface-vfunc-lookup c-lass g-name)
  (g-interface-info-find-vfunc (!info c-lass) g-name))


;; Below is a copy of the (define-syntax method ...) code in (oop goops) - a
;; copy just slightly altered, changing <method> occurrences to <vfunc>. I
;; actualy had to do this, rather then merely call (make <vfunc ...), because
;; this syntax is full of internal defs that one also needs when subclassing
;; <method>.

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

    (define (compute-make-procedure formals body next-method)
      (syntax-case body ()
        ((body ...)
         (with-syntax ((next-method next-method))
           (syntax-case formals ()
             ((formal ...)
              #'(lambda (real-next-method)
                  (lambda (formal ...)
                    (let ((next-method (lambda args
                                         (if (null? args)
                                             (real-next-method formal ...)
                                             (apply real-next-method args)))))
                      body ...))))
             (formals
              (with-syntax (((formal ...) (->proper #'formals)))
                #'(lambda (real-next-method)
                    (lambda formals
                      (let ((next-method (lambda args
                                           (if (null? args)
                                               (apply real-next-method formal ...)
                                               (apply real-next-method args)))))
                        body ...))))))))))

    (define (compute-procedures formals body)
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

    (syntax-case x ()
      ((_ args) #'(vfunc args (if #f #f)))
      ((_ args body0 body1 ...)
       (with-syntax (((formals (specializer ...)) (parse-args #'args)))
         (call-with-values
             (lambda ()
               (compute-procedures #'formals #'(body0 body1 ...)))
           (lambda (procedure make-procedure)
             (with-syntax ((procedure procedure)
                           (make-procedure make-procedure))
               #'(make <vfunc>
                   #:specializers (cons* specializer ...)
                   #:formals 'formals
                   #:body '(body0 body1 ...)
                   #:make-procedure make-procedure
                   #:procedure procedure)))))))))
