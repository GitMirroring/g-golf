;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2024
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


(define-module (tests gobject)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (oop goops)
  #:use-module (unit-test)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last))


(define-class <g-golf-test-gobject> (<test-case>))


;;;
;;; type info
;;;

(define-method (test-g-type-name (self <g-golf-test-gobject>))
  (assert-equal "GObject" (g-type-name (!g-type <gobject>)))
  (assert-equal "gfloat" (g-type-name 56)))

(define-method (test-g-type-from-name (self <g-golf-test-gobject>))
  (assert (g-type-from-name "GObject"))
  (assert-false (g-type-from-name "GObject3")))

(define-method (test-g-type-class-* (self <g-golf-test-gobject>))
  (let* ((g-type (!g-type <gobject>))
         (g-class (assert (g-type-class-ref g-type))))
    (assert (g-type-class-peek g-type))
    (assert (g-type-ensure g-type))
    (assert (g-type-class-unref g-class))))

(define-method (test-g-type-query (self <g-golf-test-gobject>))
  (let ((g-type (!g-type <gobject>)))
    (assert (g-type-query g-type))))

(define-method (test-g-type-register-static-simple (self <g-golf-test-gobject>))
  (match (g-type-query (!g-type <gobject>))
    ((g-type type-name class-size instance-size)
     (assert (g-type-register-static-simple g-type
                                            (class-name->g-name '<foo-bar>)
                                            136
                                            #f  ;; class-init-func
                                            24
                                            #f  ;; instance-init-func
                                            '())))))

(define-method (test-g-type-add-interface-static (self <g-golf-test-gobject>))
  (gi-import-by-name "Gio" "File")
  ;; we registered the FooBar type in the above test, but at compile time,
  ;; <foo-bar> would not be defined, hence we (exceptionally) call
  ;; g-type-from-name.
  (assert (g-type-add-interface-static (g-type-from-name "FooBar")
                                       (!g-type <g-file>)
                                       #f)))


;;;
;;; GObject
;;;


(define-method (test-g-object-class-find-property (self <g-golf-test-gobject>))
  (assert
   (g-object-class-find-property (!g-class <g-binding>)
                                 "source"))
  (assert-false
   (g-object-class-find-property (!g-class <g-binding>)
                                 "unknown")))

(define-method (test-g-object-class-list-properties (self <g-golf-test-gobject>))
  (assert-true (receive (props n-prop)
                   (g-object-class-list-properties (!g-class <g-binding>))
                 (= (length props) n-prop))))


;;;
;;; Genric values
;;;

(define-method (test-g-value-size (self <g-golf-test-gobject>))
  (assert (g-value-size)))

(define-method (test-g-value-init (self <g-golf-test-gobject>))
  (assert (g-value-init (symbol->g-type 'float))))

(define-method (test-g-value-unset (self <g-golf-test-gobject>))
  (assert (g-value-unset
           (g-value-init (symbol->g-type 'float)))))

(define-method (test-g-value-type* (self <g-golf-test-gobject>))
  (let* ((g-type (!g-type <gobject>))
         (g-value (g-value-init g-type)))
    (assert-true (= (g-value-type g-value) g-type))
    (assert-true (string=? (g-value-type-name g-value)
                           "GObject"))
    (assert-true (eq? (g-value-type-tag g-value) 'object))))

(define-method (test-g-value-get-boolean (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'boolean))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-boolean (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'boolean))))
    (assert (g-value-set! g-value #f))
    (assert-false (g-value-ref g-value))
    (assert (g-value-set! g-value 'true))
    (assert-true (g-value-ref g-value))))

(define-method (test-g-value-get-int (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'int))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-int (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'int))))
    (assert (g-value-set! g-value 5))
    (assert (g-value-set! g-value -5))))

(define-method (test-g-value-get-uint (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'uint))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-uint (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'uint))))
    (assert (g-value-set! g-value 5))))

(define-method (test-g-value-get-float (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'float))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-float (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'float))))
    (assert (g-value-set! g-value 5.0))))

(define-method (test-g-value-get-double (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'double))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-double (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'double))))
    (assert (g-value-set! g-value 5.0))))

#!

;; Can't find a registered enum (that has a GType) in GObject so,
;; temporarily comment those two tests -

(define-method (test-g-value-get-enum (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init %align-info-g-type)))
    (assert (g-value-ref g-value))))


(define-method (test-g-value-set-enum (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init %align-info-g-type)))
    (assert (g-value-set! g-value 1))
    (assert (g-value-set! g-value 'start))))

!#

(define-method (test-g-value-get-flags (self <g-golf-test-gobject>))
  (let* ((binding-flags (gi-cache-ref 'flags 'g-binding-flags))
         (g-value (g-value-init (!g-type binding-flags))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-flags (self <g-golf-test-gobject>))
  (let* ((binding-flags (gi-cache-ref 'flags 'g-binding-flags))
         (g-value (g-value-init (!g-type binding-flags))))
    (assert (g-value-set! g-value '(sync-create)))))

(define-method (test-g-value-get-string (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'string))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-string (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'string))))
    (assert (g-value-set! g-value #f))
    (assert (g-value-set! g-value ""))
    (assert (g-value-set! g-value "Hello!"))
    (assert (g-value-set! g-value "Apresentação"))))

(define-method (test-g-value-get-param (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'param))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-param (self <g-golf-test-gobject>))
  (let* ((g-value (g-value-init (symbol->g-type 'param)))
         (g-class (!g-class <g-binding>))
         (p-spec (assert
                  (g-object-class-find-property g-class "source"))))
    (assert (g-value-set! g-value #f))
    (assert (g-value-set! g-value p-spec))
    (assert-true (eq? (pointer-address (g-value-ref g-value))
                      (pointer-address p-spec)))))

(define-method (test-g-value-boxed-semi-opaque (self <g-golf-test-gobject>))
  (let* ((port (open "/dev/tty" O_RDONLY))
         (fd (fileno port))
         (channel (g-io-channel-unix-new fd))
         (gio-channel (gi-cache-ref 'boxed 'gio-channel))
         (g-type (slot-ref gio-channel 'g-type))
         (g-value (g-value-init g-type)))
    (assert (g-value-set! g-value channel))
    (assert-true (eq? (pointer-address (g-value-ref g-value))
                      (pointer-address channel)))
    (close port)))

(define-method (test-g-value-boxed-g-strv (self <g-golf-test-gobject>))
  (let* ((g-type (g-strv-get-type))
         (g-value (g-value-init g-type))
         (value '("one" "two" "three")))
    (assert (g-value-set! g-value '()))
    (assert-equal (g-value-ref g-value) '())
    (assert (g-value-set! g-value value))
    (assert-equal (g-value-ref g-value) value)))

(define-method (test-g-value-get-pointer (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'pointer))))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-pointer (self <g-golf-test-gobject>))
  (let ((g-value (g-value-init (symbol->g-type 'pointer))))
    (assert (g-value-set! g-value g-value))))

(define-method (test-g-value-get-object (self <g-golf-test-gobject>))
  (let* ((g-type (symbol->g-type 'object))
         (g-value (g-value-init g-type)))
    (assert (g-value-ref g-value))))

(define-method (test-g-value-set-object (self <g-golf-test-gobject>))
  (let* ((g-type (symbol->g-type 'object))
         (inst (make <gobject>))
         (g-value (g-value-init g-type)))
    (assert (g-value-set! g-value (!g-inst inst)))))


;;;
;;; Parameter and Values
;;;

(define-method (test-g-params-vals (self <g-golf-test-gobject>))
  (assert (g-type-param-boolean))
  (assert (g-type-param-char))
  (assert (g-type-param-uchar))
  (assert (g-type-param-int))
  (assert (g-type-param-uint))
  (assert (g-type-param-long))
  (assert (g-type-param-ulong))
  (assert (g-type-param-int64))
  (assert (g-type-param-uint64))
  (assert (g-type-param-float))
  (assert (g-type-param-double))
  (assert (g-type-param-enum))
  (assert (g-type-param-flags))
  (assert (g-type-param-string))
  (assert (g-type-param-param))
  (assert (g-type-param-boxed))
  (assert (g-type-param-pointer))
  (assert (g-type-param-object))
  (assert (g-type-param-unichar))
  (assert (g-type-param-override))
  (assert (g-type-param-gtype))
  (assert (g-type-param-variant)))


;;;
;;; Param Spec
;;;

(define-method (test-g-param-spec (self <g-golf-test-gobject>))
  (let* ((g-class (!g-class <g-binding>))
         (p-spec (assert
                  (g-object-class-find-property g-class "source"))))
    (assert (g-param-spec-type p-spec))
    (assert (g-param-spec-type-name p-spec))
    (assert (g-param-spec-get-default-value p-spec))
    (assert (g-param-spec-get-name p-spec))
    (assert (g-param-spec-get-nick p-spec))
    (assert (g-param-spec-get-blurb p-spec))
    (assert (g-param-spec-get-flags p-spec))))


;;;
;;; Signals
;;;

(define-method (test-g-signal-parse-name (self <g-golf-test-gobject>))
  (let ((g-type (!g-type <g-binding>)))
    (assert (g-signal-parse-name "notify" g-type))
    (assert (g-signal-parse-name 'notify g-type))
    (assert (g-signal-parse-name "notify::target" g-type))
    (assert (g-signal-parse-name 'notify::target g-type))
    (assert-exception (g-signal-parse-name "notified" g-type))
    (assert-exception (g-signal-parse-name 'notified g-type))
    (assert-exception (g-signal-parse-name "notified::target" g-type))
    (assert-exception (g-signal-parse-name 'notified::target g-type))))


(exit-with-summary (run-all-defined-test-cases))
