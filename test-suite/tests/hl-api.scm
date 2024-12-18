;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2023
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


(define-module (tests hl-api)
  #:use-module (ice-9 threads)
  #:use-module (oop goops)
  #:use-module (unit-test)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last))


(define-class <g-golf-test-hl-api> (<test-case>))


;;;
;;; n-decl
;;;

(define-method (test-n-decl-1.1 (self <g-golf-test-hl-api>))
  (assert (g-name-transform-exception))
  (assert-true (g-name-transform-exception? "GObject"))
  (assert-false (g-name-transform-exception? "GEnum"))
  (assert (g-name-transform-exception-add "GEnum" "genum"))
  (assert-true (g-name-transform-exception? "GEnum"))
  (assert (g-name-transform-exception-remove "GEnum"))
  (assert-false (g-name-transform-exception? "GEnum"))
  ;; removing "GObject" is a no op
  (assert (g-name-transform-exception-remove "GObject"))
  (assert-true (g-name-transform-exception? "GObject"))
  (assert (g-name-transform-exception-add "GEnum" "genum"))
  (assert (g-name-transform-exception-reset))
  (assert-false (g-name-transform-exception? "GEnum"))
  (assert-true (g-name-transform-exception? "GObject")))

(define-method (test-n-decl-1.2 (self <g-golf-test-hl-api>))
  (assert (g-studly-caps-expand-token-exception))
  (assert-true (g-studly-caps-expand-token-exception? "WebKit"))
  (assert-false (g-studly-caps-expand-token-exception? "BlueFox"))
  (assert (g-studly-caps-expand-token-exception-add "BlueFox" "bluefox"))
  (assert-true (g-studly-caps-expand-token-exception? "BlueFox"))
  (assert (g-studly-caps-expand-token-exception-remove "BlueFox"))
  (assert-false (g-studly-caps-expand-token-exception? "BlueFox"))
  ;; removing "GObject" is a no op
  (assert (g-studly-caps-expand-token-exception-remove "WebKit"))
  (assert-true (g-studly-caps-expand-token-exception? "WebKit"))
  (assert (g-studly-caps-expand-token-exception-add "BlueFox" "bluefos"))
  (assert (g-studly-caps-expand-token-exception-reset))
  (assert-false (g-studly-caps-expand-token-exception? "BlueFox"))
  (assert-true (g-studly-caps-expand-token-exception? "WebKit")))

(define-method (test-n-decl-2 (self <g-golf-test-hl-api>))
  (assert-true (eq? (gi-strip-boolean-result) '()))
  (assert-false (gi-strip-boolean-result? 'gdk-event-get-axis))
  (assert (gi-strip-boolean-result-add gdk-event-get-axis
                                       gdk-event-get-button
                                       gdk-event-get-click-count
                                       gdk-event-get-coords
                                       gdk-event-get-keycode
                                       gdk-event-get-keyval
                                       gdk-event-get-root-coords
                                       gdk-event-get-scroll-direction
                                       gdk-event-get-scroll-deltas
                                       gdk-event-get-state))
  (gi-strip-boolean-result-add gdk-event-get-axis)
  (assert-true (= 10 (length (gi-strip-boolean-result))))
  (assert-true (gi-strip-boolean-result? 'gdk-event-get-axis))
  (assert (gi-strip-boolean-result-remove gdk-event-get-axis))
  (assert-false (gi-strip-boolean-result? 'gdk-event-get-axis))
  (assert (gi-strip-boolean-result-reset))
  (assert-true (eq? (gi-strip-boolean-result) '())))

(define-method (test-n-decl-3.1 (self <g-golf-test-hl-api>))
  (assert-true (eq? (gi-method-short-name-skip) '()))
  (assert-false (gi-method-short-name-skip? 'gdk-event-get-axis))
  (assert (gi-method-short-name-skip-add gdk-event-get-axis
                                         gdk-event-get-button
                                         gdk-event-get-click-count
                                         gdk-event-get-coords
                                         gdk-event-get-keycode
                                         gdk-event-get-keyval
                                         gdk-event-get-root-coords
                                         gdk-event-get-scroll-direction
                                         gdk-event-get-scroll-deltas
                                         gdk-event-get-state))
  (gi-method-short-name-skip-add gdk-event-get-axis)
  (assert-true (= 10 (length (gi-method-short-name-skip))))
  (assert-true (gi-method-short-name-skip? 'gdk-event-get-axis))
  (assert (gi-method-short-name-skip-remove gdk-event-get-axis))
  (assert-false (gi-method-short-name-skip? 'gdk-event-get-axis))
  (assert (gi-method-short-name-skip-all))
  (assert-true (eq? (gi-method-short-name-skip) 'all))
  (assert (gi-method-short-name-skip-reset))
  (assert-true (eq? (gi-method-short-name-skip) '())))

(define-method (test-n-decl-4.1 (self <g-golf-test-hl-api>))
  (assert (syntax-name-protect-prefix))
  (assert-false (syntax-name-protect-prefix))
  (assert (syntax-name-protect-prefix-set '_))
  (assert-equal '_ (syntax-name-protect-prefix))
  (assert (syntax-name-protect-prefix-reset))
  (assert-false (syntax-name-protect-prefix)))

(define-method (test-n-decl-4.2 (self <g-golf-test-hl-api>))
  (assert (syntax-name-protect-postfix))
  (assert-equal '_ (syntax-name-protect-postfix))
  (assert (syntax-name-protect-postfix-set #f))
  (assert-false (syntax-name-protect-postfix))
  (assert (syntax-name-protect-postfix-reset))
  (assert-equal '_ (syntax-name-protect-postfix)))

(define-method (test-n-decl-4.3 (self <g-golf-test-hl-api>))
  (assert (syntax-name-protect-renamer))
  (assert-false (syntax-name-protect-renamer))
  (assert (syntax-name-protect-renamer-set
           (lambda (name)
             (symbol-append 'blue- name '-fox))))
  (assert-true (procedure? (syntax-name-protect-renamer)))
  (assert (syntax-name-protect-renamer-reset))
  (assert-false (syntax-name-protect-renamer)))


;;;
;;;
;;;


(define-class <foo> (<gobject>)
  (bar #:g-param `(int
                   #:minimum -100 #:maximum 100 #:default 42)
       #:accessor !bar))

(define-class <baz> (<foo>)
  (zap #:g-param `(int
                   #:minimum -10 #:maximum 10 #:default 3)
       #:accessor !zap))

(define-method (test-g-property-accessor (self <g-golf-test-hl-api>))
  (let ((a-foo (make <foo>)))
    (assert-true (= (!bar a-foo) 42))
    (assert (set! (!bar a-foo) -3))
    (assert-true (= (!bar a-foo) -3))))


(define-method (test-g-property-object (self <g-golf-test-hl-api>))
  (gi-import-by-name "Gtk" "Window" #:version "3.0")
  (gi-import-by-name "Gtk" "init" #:version "3.0")
  (gtk-init #f)
  (let ((window1 (make <gtk-window> #:type 'toplevel))
        (window2 (make <gtk-window> #:type 'toplevel)))
    (assert (set! (!transient-for window2) window1))
    (assert-true (eq? (!transient-for window2)
                      window1))))


(define-method (test-accessor-inheritance (self <g-golf-test-hl-api>))
  (let* ((a-baz (make <baz>)))
    (assert-true (= (!bar a-baz) 42))
    (assert (set! (!bar a-baz) -3))
    (assert-true (= (!bar a-baz) -3))))


(define-method (test-closure-enum (self <g-golf-test-hl-api>))
  (let* ((enum %gi-type-tag)
         (closure (make <closure>
                    #:function (lambda (a) a)
                    #:return-type enum
                    #:param-types (list enum))))
    (assert-true (eq? (invoke closure 'interface)
                      'interface))
    (assert (free closure))))


(define-method (test-closure-gi-enum (self <g-golf-test-hl-api>))
  (let* ((enum %gi-type-tag)
         (closure (make <closure>
                    #:function (lambda (a) a)
                    #:return-type enum
                    #:param-types (list enum))))
    (assert-true (eq? (invoke closure 'uint8)
                      'uint8))
    (assert (free closure))))


(define-method (test-closure-flags (self <g-golf-test-hl-api>))
  (let* ((flags %g-type-fundamental-flags)
         (closure (make <closure>
                    #:function (lambda (a) a)
                    #:return-type flags
                    #:param-types (list flags))))
    (assert-true (let ((result (invoke closure '(classed))))
                   (eq? (car result) 'classed)))
    (assert (free closure))))


(define-method (test-closure-gi-flags (self <g-golf-test-hl-api>))
  (let* ((flags (gi-cache-ref 'flags 'g-binding-flags))
         (closure (make <closure>
                    #:function (lambda (a) a)
                    #:return-type flags
                    #:param-types (list flags))))
    (assert-true (let ((result (invoke closure '(sync-create))))
                   (eq? (car result) 'sync-create)))
    (assert (free closure))))


(define-method (test-closure-gobject (self <g-golf-test-hl-api>))
  (let* ((object (make <gobject>))
         (closure (make <closure>
                    #:function (lambda (a) a)
                    #:return-type <gobject>
                    #:param-types (list <gobject>))))
    (assert-true (eq? (invoke closure object)
                      object))
    (assert (free closure))))


(define-method (test-closure-sum (self <g-golf-test-hl-api>))
  (let ((closure (make <closure>
                   #:function (lambda (a b) (+ a b))
                   #:return-type 'int
                   #:param-types '(int int))))
    (assert-true (= (invoke closure 2 3) 5))
    (assert (free closure))))


(define-method (test-g-idle-add (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-idle-add (lambda ()
                                     (g-main-loop-quit loop)
                                     #f)))))
    (g-main-loop-run loop)))


(define-method (test-g-timeout-add (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-timeout-add 1000
                                      (lambda ()
                                        (g-main-loop-quit loop)
                                        #f)))))
    (g-main-loop-run loop)))


(define-method (test-g-timeout-add-seconds (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-timeout-add-seconds 1
                                              (lambda ()
                                                (g-main-loop-quit loop)
                                                #f)))))
    (g-main-loop-run loop)))


#!

;; as discussed in #gtk, calling make-thread is the route for problems
;; with the main context ... or it cancels the thread before the timeout
;; triggers or some other problem  related to threads

(define-method (test-g-idle-add (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-idle-add (lambda ()
                                     'ok
                                     #f))))
         (thread (make-thread g-main-loop-run loop)))
    (cancel-thread thread)))


(define-method (test-g-timeout-add (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-timeout-add 1000
                                      (lambda ()
                                        'ok
                                        #f))))
         (thread (make-thread g-main-loop-run loop)))
    (cancel-thread thread)))


(define-method (test-g-timeout-add-seconds (self <g-golf-test-hl-api>))
  (let* ((loop (g-main-loop-new #f #f))
         (idle (assert (g-timeout-add-seconds 1
                                              (lambda ()
                                                'ok
                                                #f))))
         (thread (make-thread g-main-loop-run loop)))
    (cancel-thread thread)))

!#


;;;
;;; GList - GSList
;;;

(define-method (test-glist-gslist->scm (self <g-golf-test-hl-api>))
  (gi-import-by-name "Gtk" "RadioMenuItem" #:version "3.0")
  (gi-import-by-name "Gtk" "init" #:version "3.0")
  (gtk-init #f)
  (let ((item-1 (make <gtk-radio-menu-item> #:label "Item 1"))
        (item-2 (make <gtk-radio-menu-item> #:label "Item 2")))
    (gtk-radio-menu-item-join-group item-1 item-2)
    (let ((lst1 (assert (gtk-radio-menu-item-get-group item-1)))
          (lst2 (assert (gtk-radio-menu-item-get-group item-2))))
      (assert-true (equal? lst1
                           lst2
                           (list item-1 item-2))))))


(exit-with-summary (run-all-defined-test-cases))
