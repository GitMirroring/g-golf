;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2024
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


(define-module (g-golf hl-api closure)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module ((srfi srfi-1) #:select (member))
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api argument)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)
  
  #:export (<closure>

            %gi-closure-cache
            gi-closure-cache-ref
            gi-closure-cache-set!
            gi-closure-cache-remove!
            gi-closure-cache-for-each
            gi-closure-cache-show))


(g-export !g-closure
          !function
          !return-type
          !param-types
          !param-args
          !g-value-ptr?

          invoke
          free)


(define-class <closure> ()
  (g-closure #:accessor !g-closure)
  (function #:accessor !function #:init-keyword #:function)
  (return-type #:accessor !return-type
               #:init-keyword #:return-type #:init-value #f)
  (param-types #:accessor !param-types
               #:init-keyword #:param-types #:init-value #f)
  (param-args #:accessor !param-args
              #:init-keyword #:param-args #:init-value #f)
  (g-value-ptr? #:accessor !g-value-ptr?
                #:init-keyword #:g-value-ptr? #:init-value #f))

(define-method (initialize (self <closure>) initargs)
  ;; This method used to force the #:return-type and #:param-types
  ;; keywords as well, but this was actually a missunderstanding of how
  ;; GClosure really work. GObject actually fills the GClosure with
  ;; those: "... Closures allow the callee to get the types of the
  ;; callback parameters, which means that language bindings don’t have
  ;; to write individual glue for each callback type."
  (let ((function (or (get-keyword #:function initargs #f)
                      (error "Missing #:function initarg: " initargs)))
        (g-closure (g-closure-new-simple (g-closure-size) #f)))
    (next-method)
    (set! (!g-closure self) g-closure)
    (gi-closure-cache-set! g-closure self)
    (g-closure-ref g-closure)
    (g-closure-sink g-closure)
    (g-closure-set-marshal g-closure %g-closure-marshal)
    (g-closure-add-invalidate-notifier g-closure
                                       #f
                                       %g-closure-invalidate-notifier)))

#!

;; For debugging purposes, kept them for a little while just in case.

(define %g-closure-invoke-args #f)
(export %g-closure-invoke-args)

;; so one can 'directly' debug g-closure-invoke in a repl
#;(set! %g-closure-invoke-args
      (list (!g-closure self)
            return-val
            n-param
            param-vals
            #f))

!#

(define-method (invoke (self <closure>) . args)
  (let* ((%g-value-size (g-value-size))
        (return-type (!return-type self))
        (return-val? (not (eq? return-type 'none)))
        (return-val (if return-val?
                          (bytevector->pointer
                           (make-bytevector %g-value-size 0))
                          %null-pointer))
        (param-types (!param-types self))
        (n-param (length param-types))
        (param-vals (if (= n-param 0)
                        %null-pointer
                        (bytevector->pointer
                         (make-bytevector (* n-param %g-value-size) 0)))))
    (if (= (length args) n-param)
        (begin
          (when return-val?
            (prepare-return-val return-val return-type))
          (let loop ((i 0)
                     (g-value param-vals))
            (if (= i n-param)
                'done
                (let ((type (list-ref param-types i))
                      (val (list-ref args i)))
                  (prepare-g-value-in g-value type val)
                  (loop (+ i 1)
                        (gi-pointer-inc g-value %g-value-size)))))
          (g-closure-invoke (!g-closure self)
                            return-val
                            n-param
                            param-vals
                            #f) ;; invocation-hint
          (if return-val?
              (return-val->scm return-type return-val)
              (values)))
        (error "Argument arity mismatch: " args))))

(define-method (free (self <closure>))
  (let ((g-closure (!g-closure self)))
    ;; Note that g-closure-free will unref g-closure till its ref_count
    ;; reaches 0. This will trigger a call to the g-closure invalidate
    ;; notifier, which ensures its entry in the gi-closure-cache is
    ;; removed (so we don't need to do this here).
    (g-closure-free g-closure)))

(define %g_value_init
  (@@ (g-golf gobject generic-values) g_value_init))

(define (prepare-return-val g-value type)
  (cond ((or (is-a? type <gi-flags>)
             (is-a? type <gi-enum>))
         (let ((g-type (!g-type type)))
           (%g_value_init g-value (or g-type
                                      (symbol->g-type 'int)))))
        #;((boxed))
        #;((param))
        ((gobject-class? type)
         (%g_value_init g-value (!g-type type)))
        (else
         (%g_value_init g-value (symbol->g-type type)))))

(define (prepare-g-value-in g-value type val)
  (cond ((eq? type 'boolean)
         (%g_value_init g-value (symbol->g-type type))
         (g-value-set! g-value (scm->gi val 'boolean)))
        ((is-a? type <gi-flags>)
         (let ((g-type (!g-type type)))
           (if g-type
               (begin
                 (%g_value_init g-value g-type)
                 (g-value-set! g-value val))
               (begin
                 (%g_value_init g-value (symbol->g-type 'int))
                 (g-value-set! g-value
                               (flags->integer type val))))))
        ((is-a? type <gi-enum>)
         (let ((g-type (!g-type type)))
           (if g-type
               (begin
                 (%g_value_init g-value g-type)
                 (g-value-set! g-value val))
               (begin
                 (%g_value_init g-value (symbol->g-type 'int))
                 (g-value-set! g-value (enum->value type val))))))
        ((eq? type 'string)
         (%g_value_init g-value (symbol->g-type type))
         (g-value-set! g-value (scm->gi val 'string)))
        ((eq? type 'pointer)
         (%g_value_init g-value (symbol->g-type type))
         (g-value-set! g-value (scm->gi val 'pointer)))
        #;((boxed))
        #;((param))
        ((eq? type 'object)
         (let ((g-type (!g-type (class-of val))))
           (%g_value_init g-value g-type)
           (g-value-set! g-value (!g-inst val))))
        ((gobject-class? type)
         (%g_value_init g-value (!g-type type))
         (g-value-set! g-value (!g-inst val)))
        (else
         (%g_value_init g-value (symbol->g-type type))
         (g-value-set! g-value val))))

(define (return-val->scm type g-value)
  (let ((val (g-value-ref g-value)))
    (cond ((is-a? type <gi-flags>)
           (if (!g-type type)
               val
               (integer->flags type val)))
          ((is-a? type <gi-enum>)
           (if (!g-type type)
               val
               (enum->symbol type val)))
          ((gobject-class? type)
           (and (gi->scm val 'pointer)
                (make type #:g-inst val)))
          (else
           val))))

(define (g-closure-marshal g-closure
                           return-val
                           n-param
                           param-vals
                           invocation-hint
                           marshal-data)
  (let* ((%g-value-size (g-value-size))
         (closure (gi-closure-cache-ref g-closure))
         (function (!function closure))
         (param-args (!param-args closure))
         (g-value-ptr? (!g-value-ptr? closure))
         (args (if (= n-param 0)
                   '()
                   (let loop ((i 0)
                              (g-value param-vals)
                              (results '()))
                     (if (= i n-param)
                         (reverse! results)
                         (loop (+ i 1)
                               (gi-pointer-inc g-value %g-value-size)
                               (cons
                                (g-closure-marshal-g-value-ref
                                 g-value
                                 (and param-args
                                      (list-ref param-args i))
                                 param-vals
                                 param-args
                                 (and g-value-ptr?
                                      (member i g-value-ptr? =)))
                                results)))))))
    (if (null-pointer? return-val)
        (begin
          (apply function args)
          (values))
        (let ((result (apply function args)))
          (g-value-set! return-val
                        (g-closure-marshal-g-value-return-val return-val result))
          (values)))))

#!

The g-closure-marshal-g-value-ref code below used to retreive the class
name of an object doing the following calls:

  ...
  (let* ((r-type (g-value-type g-value))
         (info (g-irepository-find-by-gtype r-type))
         (g-name (g-registered-type-info-get-type-name info)))
    ...)

However, there are situations, within the context of signals callback
notably, for which the type of the g-value's object pointer is a
subclass of the class described as its type in the GI info as retrieved
here above.

As an example, the second argument to a 'decicion-policy callback maybe
a WebKitResponsePolicyDecision or a WebKitNavigationPolicyDecision, both
a WebKitPolicyDecision subclass, which is what the GI info for that
signal callback argument would tell us it is ...

The solution is to simply call g-object-type-name on the object pointer
stored in the g-value.

!#

(define* (g-closure-marshal-g-value-ref g-value param-arg param-vals param-args
                                        #:optional (g-value-ptr? #f))
  (let ((value (g-value-ref g-value)))
    (case (g-value-type-tag g-value)
      ((boxed)
       (let* ((g-name (g-value-type-name g-value))
              (name (g-name->name g-name)))
         (case name
           ((g-value)
            ;; the closure arg is a g-value - i.e. <gtk-drop-target>
            ;; 'drop signal callback second arg - when that happens, we
            ;; must retrieve the scheme value (for that g-value the
            ;; signal callback 'machinery' is givig us) - unless
            ;; g-value-ptr? is #t
            (if g-value-ptr?
                (g-value-ref g-value)
                (g-closure-marshal-g-value-ref value param-arg param-vals param-args)))
           (else
            value))))
      ((object)
       (if (or (not value)
               (null-pointer? value))
           #f
           (or (g-inst-cache-ref value)
               (receive (class name g-type)
                   (g-object-find-class value)
                 (make class #:g-inst value)))))
      ((pointer)
       (if param-arg
           (let ((type-tag (!type-tag param-arg))
                 (type-desc (!type-desc param-arg))
                 (sub-type-desc (!sub-type-desc param-arg)))
             (case type-tag
               ((array)
                (match type-desc
                  ((array fixed-size is-zero-terminated param-n param-tag ptr-array)
                   (case param-tag
                     ((utf8
                       filename)
                      (if is-zero-terminated
                          (gi-strings->scm value)
                          (gi-n-string->scm value
                                            (g-value-ref-param-n param-vals
                                                                 param-args
                                                                 param-n))))
                     ((interface)
                      (match sub-type-desc
                        ((type name gi-type g-type)
                         (map (lambda (pointer)
                                (make gi-type #:g-inst pointer))
                           (if is-zero-terminated
                               (gi-pointers->scm value)
                               (gi-n-pointer->scm value
                                                  (g-value-ref-param-n param-vals
                                                                       param-args
                                                                       param-n)))))))
                     (else
                      (warning
                       "Unimplemented (g-closure-marshal-g-value-ref) type - array;"
                       (format #f "~S" type-desc)))))))))
           value))
      (else
       value))))

#!

;; Debugging material ...

(define %param-vals #f)
(define %param-args #f)
(define %param-n #f)
(define %g-value)

(export %param-vals
        %param-args
        %param-n
        %g-value)

!#

(define (g-value-ref-param-n param-vals param-args param-n)
  (let* ((%g-value-size (g-value-size))
         (g-value (gi-pointer-inc param-vals
                                  (* %g-value-size param-n)))
         (param-arg (and param-args
                         (list-ref param-args param-n))))
    ;; Debugging material ...
    #;(set! %param-vals param-vals)
    #;(set! %param-args param-args)
    #;(set! %param-n param-n)
    #;(set! %g-value g-value)
    (g-closure-marshal-g-value-ref g-value param-arg param-vals param-args)))

(define (g-closure-marshal-g-value-return-val g-value val)
  (case (g-value-type-tag g-value)
    ((object
      interface)
     (if val
         (!g-inst val)
         %null-pointer))
    (else
     val)))

(define %g-closure-marshal
  (procedure->pointer void
                      g-closure-marshal
                      (list '*			;; gclosure
                            '*			;; return-value
                            unsigned-int	;; n-param
                            '*			;; param-values
                            '*			;; invocation-hint
                            '*)))		;; marshal-data

(define (g-closure-invalidate-notifier data g-closure)
  ;; It seems to me there is a bug in g-closure-unref: it calls the
  ;; g-closure-invalidate-notifier (if there is one) when the g-closure
  ;; ref-count 'will reach' zero, but it does call it before to set the
  ;; counter ... and when I try to display its value here, it says it's
  ;; 2 (??). So, in our ivalidate notifier procedure, we can't rely on
  ;; the g-closure ref-count value to be 'correct'.  This said, it seems
  ;; the notifier will always be called if and only if the g-closure
  ;; ref-count 'will reach' zero, so we can 'assume it is zero' ... and
  ;; only remove the corresponding <closure> instance, if it hasn't been
  ;; done already, from the %gi-closure-cache.
  (let ((closure (gi-closure-cache-ref g-closure)))
    (and closure
         (gi-closure-cache-remove! g-closure))))

(define %g-closure-invalidate-notifier
  (procedure->pointer void
                      g-closure-invalidate-notifier
                      (list '*		;; data
                            '*)))	;; gclosure



;;;
;;; The gi-closure-cache
;;;

(define %gi-closure-cache #f)
(define gi-closure-cache-ref #f)
(define gi-closure-cache-set! #f)
(define gi-closure-cache-remove! #f)
(define gi-closure-cache-for-each #f)
(define gi-closure-cache-show #f)


(eval-when (expand load eval)
  (let* ((%gi-closure-cache-default-size 1013)
         (gi-closure-cache (make-hash-table
                            %gi-closure-cache-default-size))
         (gi-closure-mutex (make-mutex))
         ( %gi-closure-cache-show-prelude
           "The g-closure function cache entries are"))

    (set! %gi-closure-cache
          (lambda () gi-closure-cache))

    (set! gi-closure-cache-ref
          (lambda (g-closure)
            (with-mutex gi-closure-mutex
              (hashq-ref gi-closure-cache
                         (pointer-address g-closure)))))

    (set! gi-closure-cache-set!
          (lambda (g-closure function)
            (with-mutex gi-closure-mutex
              (hashq-set! gi-closure-cache
                          (pointer-address g-closure)
                          function))))

    (set! gi-closure-cache-remove!
          (lambda (g-closure)
            (with-mutex gi-closure-mutex
              (hashq-remove! gi-closure-cache
                             (pointer-address g-closure)))))

    (set! gi-closure-cache-for-each
          (lambda (proc)
            (with-mutex gi-closure-mutex
              (hash-for-each proc
                             gi-closure-cache))))

    (set! gi-closure-cache-show
          (lambda* (#:optional (port (current-output-port)))
            (format port "~A~%"
                    %gi-closure-cache-show-prelude)
            (letrec ((show (lambda (key value)
                             (format port "  ~S  -  ~S~%"
                                     key
                                     value))))
              (gi-closure-cache-for-each show))))))
