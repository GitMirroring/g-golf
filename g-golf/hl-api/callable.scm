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


(define-module (g-golf hl-api callable)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf override)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api events)
  #:use-module (g-golf hl-api argument)
  #:use-module (g-golf hl-api ccc)
  #:use-module (g-golf hl-api utils)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (callable-prepare-gi-arguments
            scm->gi-argument
            callable-return-value->scm
            callable-arg-out->scm
            gi-argument->scm))


#;(g-export )


(define-method (initialize (self <callable>) initargs)
  (let* ((info (or (get-keyword #:info initargs #f)
                   (error "Missing #:info initarg: " initargs)))
         (namespace (get-keyword #:namespace initargs #f))
         (g-name (get-keyword #:g-name initargs (g-base-info-get-name info)))
         (name (get-keyword #:name initargs (g-name->name g-name)))
         (return-type-info (g-callable-info-get-return-type info))
         (return-type (g-type-info-get-tag return-type-info)))
    (receive (type-desc array-type-desc)
        (type-description return-type-info #:type-tag return-type)
      (g-base-info-unref return-type-info)
      (next-method)
      (unless namespace
        (mslot-set! self
                    'namepace (g-base-info-get-namespace info)
                    'g-name g-name
                    'name name))
      (mslot-set! self
                  'can-throw-gerror (g-callable-info-can-throw-gerror info)
                  'is-method? (g-callable-info-is-method info)
                  'caller-owns (g-callable-info-get-caller-owns info)
                  'return-type return-type
                  'type-desc type-desc
                  'is-enum? (and (eq? return-type 'interface)
                                      (match type-desc
                                        ((type name gi-type g-type confirmed?)
                                         (or (eq? type 'enum)
                                             (eq? type 'flags)))))
                  'array-type-desc array-type-desc
                  'may-return-null? (g-callable-info-may-return-null info))
      (initialize-callable-arguments self))))

#;(define-method* (describe (self <callable>) #:key (port #t))
  (next-method self #:port port)
  (if (boolean? port)
      (newline)
      (newline port))
  (for-each (lambda (argument)
              (describe argument #:port port)
              (if (boolean? port)
                  (newline)
                  (newline port)))
      (!arguments self)))

(define-method (describe (self <callable>))
  (next-method)
  (newline)
  (for-each (lambda (argument)
              (describe argument)
              (newline))
      (!arguments self)))

(define (initialize-callable-arguments callable)
  (let* ((info (!info callable))
         (override? (!override? callable))
         (is-method? (!is-method? callable))
         (n-arg (g-callable-info-get-n-args info))
         (args (if is-method?
                   (list (make-instance-argument info))
                   '())))
    (let loop ((i 0)
               (arg-pos (length args))
               (al-pos '())
               (arguments args)
               (n-gi-arg-in (length args))
               (args-in args)
               (n-gi-arg-inout 0)
               (n-gi-arg-out 0)
               (args-out '()))
      (if (= i n-arg)
          (initialize-callable-arguments-final-steps callable
                                                     is-method?
                                                     n-arg
                                                     (reverse al-pos)
                                                     (reverse arguments)
                                                     (reverse args-in)
                                                     (reverse args-out)
                                                     n-gi-arg-in
                                                     n-gi-arg-out)
          (let* ((arg-info (g-callable-info-get-arg info i))
                 (argument (make <argument> #:info arg-info)))
            (case (!direction argument)
              ((in)
               (mslot-set! argument
                           'arg-pos (if override?
                                        arg-pos
                                        (+ (- arg-pos n-gi-arg-out) n-gi-arg-inout))
                           'gi-argument-in-bv-pos n-gi-arg-in)
               (loop (+ i 1)
                     (+ arg-pos 1)
                     (al-pos-check argument al-pos is-method?)
                     (cons argument arguments)
                     (+ n-gi-arg-in 1)
                     (cons argument args-in)
                     n-gi-arg-inout
                     n-gi-arg-out
                     args-out))
              ((inout)
               (mslot-set! argument
                           'arg-pos (if override?
                                        arg-pos
                                        (+ (- arg-pos n-gi-arg-out) n-gi-arg-inout))
                           'gi-argument-in-bv-pos n-gi-arg-in
                           'gi-argument-out-bv-pos n-gi-arg-out)
               (loop (+ i 1)
                     (+ arg-pos 1)
                     al-pos
                     (cons argument arguments)
                     (+ n-gi-arg-in 1)
                     (cons argument args-in)
                     (+ n-gi-arg-inout 1)
                     (+ n-gi-arg-out 1)
                     (cons argument args-out)))
              ((out)
               (mslot-set! argument
                           'arg-pos arg-pos
                           'gi-argument-out-bv-pos n-gi-arg-out)
               (loop (+ i 1)
                     (+ arg-pos 1)
                     al-pos
                     (cons argument arguments)
                     n-gi-arg-in
                     args-in
                     n-gi-arg-inout
                     (+ n-gi-arg-out 1)
                     (cons argument args-out)))))))))

(define (al-pos-check argument al-pos is-method?)
  (case (!type-tag argument)
    ((array)
     (match (!type-desc argument)
       ((array fixed-size is-zero-terminated param-n param-tag)
        (if (= param-n -1)
            al-pos
            (let* ((arg-pos (!arg-pos argument))
                   (param-n (if is-method? (+ param-n 1) param-n))
                   (u-args-ar-pos (if (< param-n arg-pos) ;; [1]
                                      (- arg-pos
                                         (+ (length al-pos) 1))
                                      (- arg-pos (length al-pos)))))
              (cons (list u-args-ar-pos
                          arg-pos ;; 'real' array pos [2]
                          param-n)
                    al-pos))))))
      (else
       al-pos)))

;; [1]

;; u-arg-ar-pos are 'shifted' to the left - compared to their 'real'
;; cble-args-ar-pos - by an amount that depens on both previous al args,
;; and whether the one being processed has its al-pos, param-n,
;; preceeding or following the array pos itself.

;; [2]

;; the 'real' array pos is the offset of the array arg in the (complete)
;; cble-args list - we need it to construct the cble-args list

(define (initialize-callable-arguments-final-steps callable
                                                   is-method?
                                                   n-arg	;; callable-info-n-args
                                                   al-pos
                                                   arguments
                                                   args-in
                                                   args-out
                                                   n-gi-arg-in
                                                   n-gi-arg-out)
  (let* ((gi-args-in-bv (if (> n-gi-arg-in 0)
                            (make-bytevector (* %gi-argument-size
                                                n-gi-arg-in)
                                             0)
                            #f))
         (gi-args-in (if gi-args-in-bv
                         (bytevector->pointer gi-args-in-bv)
                         %null-pointer))
         (gi-args-out-bv (if (> n-gi-arg-out 0)
                             (make-bytevector (* %gi-argument-size
                                                 n-gi-arg-out)
                                              0)
                             #f))
         (gi-args-out (if gi-args-out-bv
                          (bytevector->pointer gi-args-out-bv)
                          %null-pointer)))
    (when gi-args-in-bv
      (finalize-callable-arguments args-in gi-args-in-bv !gi-argument-in))
    (when gi-args-out-bv
      (finalize-callable-arguments args-out gi-args-out-bv !gi-argument-out))
    (for-each (lambda (item)
                (match item
                  ((u-pos c-pos l-pos)
                   (set! (!al-arg? (list-ref arguments l-pos)) #t))))
        al-pos)
    (mslot-set! callable
                'n-arg (if is-method? (+ n-arg 1) n-arg)
                'al-pos al-pos
                'arguments arguments
                'n-gi-arg-in n-gi-arg-in
                'args-in args-in
                'gi-args-in gi-args-in
                'gi-args-in-bv gi-args-in-bv
                'n-gi-arg-out n-gi-arg-out
                'args-out args-out
                'gi-args-out gi-args-out
                'gi-args-out-bv gi-args-out-bv
                'gi-arg-result (make-gi-argument))))

(define (finalize-callable-arguments args gi-args-bv gi-argument-acc)
  (let loop ((args args)
             (i 0))
    (match args
      (() #t)
      ((arg . rest)
       (set! (gi-argument-acc arg)
             (bytevector->pointer gi-args-bv
                                  (* i %gi-argument-size)))
       (loop rest
             (+ i 1))))))

(define (callable-prepare-gi-arguments callable args)
  (let* ((args-length (length args))
         (n-arg (!n-arg callable))
         (n-arg-in (!n-gi-arg-in callable))
         (al-pos (!al-pos callable))
         (effective-n-arg-in (- n-arg-in (length al-pos)))
         (override? (!override? callable)))
    (if (or (and override?
                 (= args-length n-arg))
            (= args-length effective-n-arg-in))
        (let ((args (if (null? al-pos)
                        args
                        (u-args->cble-args n-arg-in args al-pos))))
          (callable-prepare-gi-args-in callable args)
          (callable-prepare-gi-args-out callable args args-length n-arg))
        (scm-error 'wrong-arg-nb #f "Wrong number of arguments: ~A ~S"
                   (list (!name callable) args) #f))))

#!

;; example - to play with

(define cble-args
  '(e0 3 (ar1-0 ar1-1 ar1-2) e3 (ar2-0) 1 e6 2 (ar3-0 ar3-1)))

(define u-args
  '(e0 (ar1-0 ar1-1 ar1-2) e3 (ar2-0) e6 (ar3-0 ar3-1)))

(define al-pos
  '((1 2 1)	;; [1]
    (3 4 5)
    (5 8 7)))

;; [1]

;; 0.	u-args ar-pos
;; 1.	cble-arg ar-pos
;; 2.	cble-arg al-pos

!#

(define (u-args->cble-args n-arg-in u-args al-pos)
  (let loop ((i 0)
             (args u-args)
             (al-pos al-pos)
             (cble-args '()))
    (if (= i n-arg-in)
        (reverse! cble-args)
        (if (null? al-pos)
            (loop (+ i 1)
                  (cdr args)
                  '()
                  (cons (car args) cble-args))
            (match (car al-pos)
              ((u-pos c-pos l-pos)
               (if (= i l-pos)
                   (let ((ar (list-ref u-args u-pos)))
                     (loop (+ i 1)
                           args
                           (cdr al-pos)
                           (cons (cond ((list? ar) (length ar))
                                       ((string? ar) -1)
                                       (else
                                        (error "What array is this " ar)))
                                 cble-args)))
                   (loop (+ i 1)
                         (cdr args)
                         al-pos
                         (cons (car args) cble-args)))))))))

(define %maybe-null-exceptions
  '(child-setup-data-destroy))

(define (maybe-null-exception? name)
  (memq name %maybe-null-exceptions))

(define (callable-prepare-gi-args-in callable args)
  (when (%debug)
    (dimfi (!name callable)))
  (let ((is-method? (!is-method? callable)))
    (let loop ((arguments (!args-in callable)))
      (match arguments
        (() 'done)
        ((argument . rest)
         (let* ((arg-pos (!arg-pos argument))
                (value (list-ref args #;i arg-pos))
                (is-pointer? (!is-pointer? argument))
                (gi-argument (!gi-argument-in argument))
                (field (!gi-argument-field argument)))
           (scm->gi-argument (!type-tag argument)
                             (!type-desc argument)
                             gi-argument
                             value
                             argument
                             args
                             #:may-be-null-acc !may-be-null?
                             #:is-method? is-method?
                             #:forced-type (!forced-type argument))
           (when (%debug)
             (dimfi (format #f "~20,,,' @A:" (!name argument)) value
                    #;(gi-argument->scm  (!type-tag argument)
                                       (!type-desc argument)
                                       gi-argument-
                                       arguments
                                       ;; #:forced-type (!forced-type argument)
                                       #:is-pointer? (!is-pointer? argument)
                                       )))
           (loop rest)))))))

(define* (scm->gi-argument type-tag
                           type-desc
                           gi-argument
                           value	;; the scheme value
                           clb/arg	;; a <callable> or an <argument> instance
                           args
                           #:key (may-be-null-acc #f)
                           (is-method? #f)
                           (forced-type #f))
  (let ((%g-golf-callback-closure
         (@ (g-golf hl-api callback) g-golf-callback-closure))
        (may-be-null? (may-be-null-acc clb/arg)))
    ;; clearing references kept from a previous call.
    (mslot-set! clb/arg
                'string-pointer #f
                'bv-cache #f
                'bv-cache-ptr #f)
    (case type-tag
      ((interface)
       (match type-desc
         ((type name gi-type g-type confirmed?)
          (case type
            ((enum)
             (let ((e-val (enum->value gi-type value)))
               (if e-val
                   (gi-argument-set! gi-argument 'v-int e-val)
                   (error "No such symbol " value " in " gi-type))))
            ((flags)
             (let ((f-val (flags->integer gi-type value)))
               (if f-val
                   (gi-argument-set! gi-argument 'v-int f-val)
                   (error "No such flag(s) " value " in " gi-type))))
            ((struct)
             (case name
               ((void
                 g-value)
                ;; Struct for which the (symbol) name is void should be
                ;; considerd opaque.  Functions and methods that use
                ;; GValue(s) should be overridden-ed/manually wrapped to
                ;; initialize those g-value(s) - and here, value is
                ;; supposed to (always) be a valid pointer to an
                ;; initialized GValue.
                (gi-argument-set! gi-argument 'v-pointer value))
               (else
                (gi-argument-set! gi-argument 'v-pointer
                                  (cond ((or (!is-opaque? gi-type)
                                             (!is-semi-opaque? gi-type))
                                         value)
                                        (else
                                         (make-c-struct (!scm-types gi-type)
                                                        value)))))))
            ((union)
             (gi-argument-set! gi-argument 'v-pointer value))
            ((object
              interface)
             (gi-argument-set! gi-argument 'v-pointer
                               (if value
                                   (!g-inst value)
                                   (if may-be-null?
                                       %null-pointer
                                       (error "Invalid argument: " value)))))
            ((callback)
             (gi-argument-set! gi-argument 'v-pointer
                               (if value
                                   (%g-golf-callback-closure gi-type value)
                                   (if (or may-be-null?
                                           (maybe-null-exception? name))
                                       #f
                                       (error "Invalid argument: " value)))))))))
      ((array)
       (if (or (not value)
               (null? value))
           (if may-be-null?
               (gi-argument-set! gi-argument 'v-pointer #f)
               (error "Invalid array argument: " value))
           (match type-desc
             ((array fixed-size is-zero-terminated param-n param-tag)
              (let* ((param-n (if (= param-n -1)
                                  -1
                                  (if is-method? (+ param-n 1) param-n)))
                     (arg-n (if (= param-n -1)
                                -1
                                (list-ref args param-n))))
                (case param-tag
                  ((utf8
                    filename)
                   (gi-argument-set! gi-argument 'v-pointer
                                     (if (or is-zero-terminated
                                             (= arg-n -1))
                                         (scm->gi-strings value)
                                         (scm->gi-n-string value arg-n))))
                  ((gtype)
                   (gi-argument-set! gi-argument 'v-pointer
                                     (if (or is-zero-terminated
                                             (= arg-n -1))
                                         (warning
                                          "Unimplemented (prepare args-in) scm->gi-gtypes."
                                          "")
                                         (scm->gi-n-gtype value arg-n))))
                  ((uint8)
                   ;; this is most likely a string, but we will check
                   ;; and also (blindingly) accept a pointer.
                   (cond ((string? value)
                          (let ((string-pointer (string->pointer value)))
                            (set! (!string-pointer clb/arg) string-pointer)
                            ;; don't use 'v-string, which expects a
                            ;; string, calls string->pointer (and does
                            ;; not keep a reference).
                            (gi-argument-set! gi-argument 'v-pointer string-pointer)))
                         ((pointer? value)
                          ;; as said above, we blindingly accept a pointer
                          (gi-argument-set! gi-argument 'v-pointer value))
                         (else
                          (error "Invalid (uint8 array) argument: " value))))
                  ((interface)
                   (match (!array-type-desc clb/arg)
                     ((type name gi-type g-type confirmed?)
                      (case type
                        ((object)
                         (let ((ptrs (map !g-inst value)))
                           (gi-argument-set! gi-argument 'v-pointer
                                             (if (or is-zero-terminated
                                                     (= arg-n -1))
                                                 (scm->gi-pointers ptrs)
                                                 (scm->gi-n-pointer ptrs arg-n)))))
                        (else
                         (warning "Unimplemented (prepare args-in) type - array;"
                                  (format #f "~S" type-desc)))))))
                  (else
                   (warning "Unimplemented (prepare args-in) type - array;"
                            (format #f "~S" type-desc)))))))))
      ((glist)
       (if (or (not value)
               (null? value))
           (if may-be-null?
               (gi-argument-set! gi-argument 'v-pointer #f)
               (error "Invalid glist argument: " value))
           (warning "Unimplemented type" (symbol->string type-tag))))
      ((gslist)
       (if (or (not value)
               (null? value))
           (if may-be-null?
               (gi-argument-set! gi-argument 'v-pointer #f)
               (error "Invalid gslist argument: " value))
           (match type-desc
             ((type name gi-type g-type confirmed?)
              (case type
                ((object)
                 (gi-argument-set! gi-argument 'v-pointer
                                   (scm->gi-gslist (map !g-inst value))))
                (else
                 (warning "Unimplemented gslist subtype" type-desc)))))))
      ((ghash
        error)
       (if (not value)
           (if may-be-null?
               (gi-argument-set! gi-argument 'v-pointer #f)
               (error "Invalid " type-tag " argument: " value))
           (warning "Unimplemented type" (symbol->string type-tag))))
      ((utf8
        filename)
       ;; we need to keep a reference to string pointers, otherwise the
       ;; C string will be freed, which might happen before the C call
       ;; actually occurred.
       (if (not value)
           (if may-be-null?
               (gi-argument-set! gi-argument 'v-pointer #f)
               (error "Invalid " type-tag " argument: " #f))
           (let ((string-pointer (string->pointer value)))
             (set! (!string-pointer clb/arg) string-pointer)
             ;; don't use 'v-string, which expects a string, calls
             ;; string->pointer (and does not keep a reference).
             (gi-argument-set! gi-argument 'v-pointer string-pointer))))
      (else
       ;; Here starts fundamental types. However, we still need to check
       ;; the forced-type slot-value, and when it is a pointer, allocate
       ;; mem for the type-tag, then set the value and initialize the
       ;; gi-argument to a pointer to the alocated mem.
       (case forced-type
         ((pointer)
          (if (not value)
              (if may-be-null?
                  (gi-argument-set! gi-argument 'v-pointer #f)
                  (error "Invalid (pointer to) " type-tag " argument: " value))
              (case type-tag
                ((boolean
                  int8 uint8
                  int16 uint16
                  int32 uint32
                  int64 uint64
                  float double
                  gtype)
                 (receive (make-bv bv-ref bv-set!)
                     (gi-type-tag->bv-acc type-tag)
                 (let* ((bv-cache (!bv-cache clb/arg))
                        (bv-cache-ptr (!bv-cache-ptr clb/arg))
                        (bv (or bv-cache (make-bv 1 0)))
                        (bv-ptr (or bv-cache-ptr
                                    (bytevector->pointer bv))))
                   (unless bv-cache
                     (mslot-set! clb/arg
                                 'bv-cache bv
                                 'bv-cache-ptr bv-ptr))
                   (bv-set! bv 0 value)
                   (gi-argument-set! gi-argument 'v-pointer bv-ptr))))
                ((void)
                 ;; Till proved wrong, we'll consider those opaque
                 ;; pointers.
                 (gi-argument-set! gi-argument 'v-pointer value))
                (else
                 (warning "Unimplemented (pointer to): " type-tag)))))
         (else
          (gi-argument-set! gi-argument
                            (gi-type-tag->field type-tag)
                            value)))))))

(define (callable-prepare-gi-args-out callable args args-length n-arg)
  (let ((n-gi-arg-out (!n-gi-arg-out callable))
        (args-out (!args-out callable)))
    (let loop ((i 0))
      (if (= i n-gi-arg-out)
          #t
          (let ((arg-out (list-ref args-out i)))
            (cond ((eq? (!direction arg-out) 'inout)
                   ;; Then we 'merely' copy the content of the
                   ;; gi-argument-in to the gi-argument-out.
                   (let ((gi-argument-size %gi-argument-size)
                         (in-bv (!gi-args-in-bv callable))
                         (in-bv-pos (!gi-argument-in-bv-pos arg-out))
                         (out-bv (!gi-args-out-bv callable))
                         (out-bv-pos (!gi-argument-out-bv-pos arg-out)))
                     (bytevector-copy! in-bv
                                       (* in-bv-pos gi-argument-size)
                                       out-bv
                                       (* out-bv-pos gi-argument-size)
                                       gi-argument-size)))
                  ((and (!override? callable)
                        (= args-length n-arg))
                   ;; Then all 'out argument(s) have been provided, as a
                   ;; pointer, and what ever they point to must have
                   ;; been initialized - see (g-golf override gtk) for
                   ;; some exmples.
                   (let* ((arg-pos (!arg-pos arg-out))
                          (arg (list-ref args arg-pos)))
                     (gi-argument-set! (!gi-argument-out arg-out) 'v-pointer
                                       (scm->gi arg 'pointer))))
                  (else
                   (let* ((type-tag (!type-tag arg-out))
                          (type-desc (!type-desc arg-out))
                          (is-pointer? (!is-pointer? arg-out))
                          (may-be-null? (!may-be-null? arg-out))
                          (is-caller-allocate? (!is-caller-allocate? arg-out))
                          (forced-type (!forced-type arg-out))
                          (gi-argument-out (!gi-argument-out arg-out))
                          (field (!gi-argument-field arg-out)))
                     (case type-tag
                       ((interface)
                        (match type-desc
                          ((type name gi-type g-type confirmed?)
                           (case type
                             ((enum
                               flags)
                              (let ((bv (make-bytevector (sizeof int) 0)))
                                (gi-argument-set! gi-argument-out 'v-pointer
                                                  (bytevector->pointer bv))))
                             ((struct)
                              (case name
                                ((g-value)
                                 (gi-argument-set! gi-argument-out 'v-pointer
                                                   (g-value-new))) ;; an empty GValue
                                (else
                                 (if is-caller-allocate?
                                     (let* ((bv (make-bytevector (!size gi-type) 0))
                                            (bv-ptr (bytevector->pointer bv)))
                                       (mslot-set! arg-out
                                                   'bv-cache bv
                                                   'bv-cache-ptr bv-ptr)
                                       (gi-argument-set! gi-argument-out 'v-pointer bv-ptr))
                                     (let ((bv (make-bytevector (sizeof '*) 0)))
                                       (mslot-set! arg-out
                                                   'bv-cache #f
                                                   'bv-cache-ptr %null-pointer)
                                       (gi-argument-set! gi-argument-out 'v-pointer
                                                         (bytevector->pointer bv)))))))

                             ((object
                               interface)
                              (if is-pointer?
                                  (let ((bv (make-bytevector (sizeof '*) 0)))
                                    (gi-argument-set! gi-argument-out 'v-pointer
                                                      (bytevector->pointer bv)))
                                  (gi-argument-set! gi-argument-out 'v-pointer
                                                    %null-pointer)))))))
                       ((array)
                        (match type-desc
                          ((array fixed-size is-zero-terminated param-n param-tag)
                           ;; (gi-argument-set! gi-argument-out 'v-pointer %null-pointer)
                           (warning "Unimplemented (prepare args-out) type - array;"
                                    (format #f "~S" type-desc)))))
                       ((glist
                         gslist
                         ghash
                         error)
                        (warning "Unimplemented type" (symbol->string type-tag))
                        (gi-argument-set! gi-argument-out 'v-pointer %null-pointer))
                       ((utf8
                         filename)
                        (if is-pointer?
                            (let ((bv (make-bytevector (sizeof '*) 0)))
                              (gi-argument-set! gi-argument-out 'v-pointer
                                                (bytevector->pointer bv)))
                            (gi-argument-set! gi-argument-out 'v-pointer
                                              %null-pointer)))
                       ((boolean
                         int8 uint8
                         int16 uint16
                         int32 uint32
                         int64 uint64
                         float double
                         gtype)
                        (let* ((field (gi-type-tag->field type-tag))
                               (type (assq-ref %gi-argument-desc field))
                               (bv (make-bytevector (sizeof type) 0)))
                          (gi-argument-set! gi-argument-out 'v-pointer
                                            (bytevector->pointer bv))))
                       (else
                        ;; not sure, but this shouldn't arm.
                        (warning "Unimplemented type" (symbol->string type-tag))
                        (gi-argument-set! gi-argument-out 'v-ulong 0))))))
            (loop (+ i 1)))))))

(define (callable-arg-out->scm argument)
  (let ((type-tag (!type-tag argument))
        (type-desc (!type-desc argument))
        (gi-argument (!gi-argument-out argument))
        (forced-type (!forced-type argument))
        (is-pointer? (!is-pointer? argument)))
    (gi-argument->scm type-tag
                      type-desc
                      gi-argument
                      argument		;; the type-desc instance 'owner'
                      #:forced-type forced-type
                      #:is-pointer? is-pointer?)))

(define* (callable-return-value->scm callable #:key (args-out #f))
  (let ((type-tag (!return-type callable))
        (type-desc (!type-desc callable))
        (gi-argument (!gi-arg-result callable)))
    (gi-argument->scm type-tag
                      type-desc
                      gi-argument
                      callable 		;; the type-desc instance 'owner'
                      #:args-out args-out)))

(define* (gi-argument->scm type-tag type-desc gi-argument clb/arg
                           #:key (forced-type #f)
                           (is-pointer? #f)
                           (args-out #f)
                           (g-value-ptr? #f))
  ;; forced-type is only used for 'inout and 'out arguments, in which
  ;; case it is 'pointer - see 'simple' types below.

  ;; clb/arg is the instance that owns the type-desc, which might need to
  ;; be updated - see the comment in the 'interface/'object section of
  ;; the code below, as well as the comment in registered-type->gi-type
  ;; which explains why/when this might happen.
  (case type-tag
    ((interface)
     (match type-desc
       ((type name gi-type g-type confirmed?)
        (case type
          ((enum)
           (let ((val (case forced-type
                        ((pointer)
                         (let* ((foreign (gi-argument-ref gi-argument 'v-pointer))
                                (bv (pointer->bytevector foreign (sizeof int))))
                           (s32vector-ref bv 0)))
                        (else
                         (gi-argument-ref gi-argument 'v-int)))))
             (or (enum->symbol gi-type val)
                 (error "No such " name " value: " val))))
          ((flags)
           (let ((val (case forced-type
                        ((pointer)
                         (let* ((foreign (gi-argument-ref gi-argument 'v-pointer))
                                (bv (pointer->bytevector foreign (sizeof int))))
                           (s32vector-ref bv 0)))
                        (else
                         (gi-argument-ref gi-argument 'v-int)))))
             (integer->flags gi-type val)))
          ((struct)
           (let* ((gi-arg-val (gi-argument-ref gi-argument 'v-pointer))
                  (foreign (if is-pointer?
                               (dereference-pointer gi-arg-val)
                               gi-arg-val)))
             (case name
               ((g-value)
                (if g-value-ptr?
                    foreign
                    (g-value-ref foreign)))
               (else
                (if (or (!is-opaque? gi-type)
                        (!is-semi-opaque? gi-type))
                    (let ((bv (slot-ref clb/arg 'bv-cache))
                          (bv-ptr (slot-ref clb/arg 'bv-cache-ptr)))
                      (if bv
                          (begin
                            (g-boxed-sa-guard bv-ptr bv)
                            bv-ptr)
                          ;; when bv is #f, it (indirectly) means that
                          ;; memory is allocated by the callee
                          (if (null-pointer? foreign)
                              #f
                              (begin
                                #;(g-boxed-ga-guard foreign g-type)
                                foreign))))
                    (parse-c-struct foreign (!scm-types gi-type)))))))
          ((union)
           (let ((foreign (gi-argument-ref gi-argument 'v-pointer)))
             (case name
               ((gdk-event)
                 ;; This means that we are in gdk3/gtk3 environment,
                 ;; where the <gdk-event> class and accessors are (must
                 ;; be) defined dynamically - hence (gdk-event-class)
                (and foreign
                     (make (gdk-event-class) #:event foreign)))
               (else
                foreign))))
          ((object
            interface)
           (let* ((gi-arg-val (gi-argument-ref gi-argument 'v-pointer))
                  (foreign (if is-pointer?
                               (dereference-pointer gi-arg-val)
                               gi-arg-val)))
             (case name
               ((<g-param>) foreign)
               (else
                (and foreign
                     (not (null-pointer? foreign))
                     (receive (class name g-type)
                         (g-object-find-class foreign)
                       ;; We used to update the clb/arg 'type-desc
                       ;; argument when it wasn't confirmed?, but that
                       ;; actually won't work anymore, see the comment
                       ;; labeled [1] in (g-golf hl-api gobject) for a
                       ;; complete description. However, I'll keep the
                       ;; code, commented, for now, until I clear all
                       ;; occurrences of the confirmed? pattern entries.
                       #;(unless confirmed?
                         (set! (!type-desc clb/arg)
                               (list 'object name class g-type #t)))
                       (make class #:g-inst foreign)))))))))))
    ((array)
     (match type-desc
       ((array fixed-size is-zero-terminated param-n param-tag)
        (case param-tag
          ((utf8
            filename)
           (gi->scm (gi-argument-ref gi-argument 'v-pointer) 'strings))
          ((gtype)
           (let ((array-ptr (gi-argument-ref gi-argument 'v-pointer)))
             (if is-zero-terminated
                 (gi->scm array-ptr 'gtypes)
                 (gi->scm array-ptr 'n-gtype (list-ref args-out param-n)))))
          (else
           (warning "Unimplemented (arg-out->scm) type - array;"
                    (format #f "~S" type-desc)))))))
    ((glist
      gslist)
     (let* ((g-first (gi-argument-ref gi-argument 'v-pointer))
            (lst (gi->scm g-first type-tag)))
       (if (null? lst)
           lst
           (match type-desc
             ((type name gi-type g-type confirmed?)
              (case type
                ((object)
                 (match lst
                   ((x . rest)
                    (receive (class name g-type)
                        (g-object-find-class x)
                      (map (lambda (item)
                             (make class #:g-inst item))
                        lst)))))
                (else
                 (warning "Unprocessed g-list/g-slist"
                          (format #f "~S" type-desc))
                 lst)))))))
    ((ghash
      error)
     (warning "Unimplemented type" (symbol->string type-tag)))
    ((utf8
      filename)
     (let* ((gi-arg-val (gi-argument-ref gi-argument 'v-pointer))
            (foreign (if is-pointer?
                         (dereference-pointer gi-arg-val)
                         gi-arg-val)))
       (gi->scm foreign 'string)))
    ((gtype)
     (gi-argument-ref gi-argument
                      (gi-type-tag->field 'gtype)))
    ((void)
     (let* ((gi-arg-val (gi-argument-ref gi-argument 'v-pointer))
            (foreign (if is-pointer?
                         (dereference-pointer gi-arg-val)
                         gi-arg-val)))
       (gi->scm foreign 'pointer)))
    (else
     ;; Here starts 'simple' types, but we still need to check the
     ;; forced-type: when it is 'pointer (which happens for 'inout and
     ;; 'out arguments, not for returned values), the the gi-argument
     ;; holds a pointer to the value, otherwise, it holds the value.
     (case forced-type
       ((pointer)
        (let ((foreign (gi-argument-ref gi-argument 'v-pointer)))
          (and foreign
               (case type-tag
                 ((boolean
                   int8 uint8
                   int16 uint16
                   int32 uint32
                   int64 uint64
                   float double
                   gtype)
                  (receive (make-bv bv-ref bv-set!)
                      (gi-type-tag->bv-acc type-tag)
                    (let* ((field (gi-type-tag->field type-tag))
                           (type (assq-ref %gi-argument-desc field))
                           (bv (pointer->bytevector foreign (sizeof type)))
                           (val (bv-ref bv 0)))
                      (case type-tag
                        ((boolean)
                         (gi->scm val 'boolean))
                        (else
                         val)))))
                 ((void)
                  ;; Till proved wrong, we'll consider those opaque
                  ;; pointers.
                  foreign)
                 (else
                  (warning "Unimplemeted (pointer to) type-tag: " type-tag)
                  (gi->scm foreign 'pointer))))))
       (else
        (gi-argument-ref gi-argument
                         (gi-type-tag->field type-tag)))))))


;;;
;;; Method instance argument
;;;

(define (make-instance-argument info)
  (let* ((container (g-base-info-get-container info))
         (g-name (g-base-info-get-name container))
         (name (g-name->name g-name))
         (type (g-base-info-get-type container)))
    (receive (id r-name gi-type confirmed?)
        (registered-type->gi-type container type)
      (g-base-info-unref container)
      (make <argument>
        #:info 'instance
        #:g-name g-name
        #:name name
        #:direction 'in
        #:type-tag 'interface
        #:type-desc (list type r-name gi-type id confirmed?)
        #:is-enum? #f
        #:forced-type 'pointer
        #:is-pointer? #t
        #:may-be-null? #f
        #:arg-pos 0 ;; always the first argument
        #:gi-argument-field 'v-pointer))))
