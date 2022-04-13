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


(define-module (g-golf hl-api n-decl)
  #:use-module (srfi srfi-1)

  #:export (%gi-import-namespace-exceptions
            gi-namespace-import-exception?

            g-name-transform-exception
            g-name-transform-exception?
            g-name-transform-exception-add
            g-name-transform-exception-remove
            g-name-transform-exception-reset

            g-studly-caps-expand-token-exception
            g-studly-caps-expand-token-exception?
            g-studly-caps-expand-token-exception-add
            g-studly-caps-expand-token-exception-remove
            g-studly-caps-expand-token-exception-reset

            g-short-name-transform-exception
            g-short-name-transform-exception?
 
            gi-strip-boolean-result
            gi-strip-boolean-result?
            gi-strip-boolean-result-add
            gi-strip-boolean-result-remove
            gi-strip-boolean-result-reset

            gi-method-short-name-skip
            gi-method-short-name-skip?
            gi-method-short-name-skip-all
            gi-method-short-name-skip-add
            gi-method-short-name-skip-remove
            gi-method-short-name-skip-reset

            syntax-name-protect-prefix
            syntax-name-protect-prefix-set
            syntax-name-protect-prefix-reset
            syntax-name-protect-postfix
            syntax-name-protect-postfix-set
            syntax-name-protect-postfix-reset
            syntax-name-protect-renamer
            syntax-name-protect-renamer-set
            syntax-name-protect-renamer-reset
            syntax-name-protect-reset))


;;;
;;;
;;;

(define %gi-import-namespace-exceptions
  '("Glib"
    "GObject"))

(define (gi-namespace-import-exception? namespace)
  (member namespace
          %gi-import-namespace-exceptions
          string=?))


;;;
;;; name transform exception
;;;

(define g-name-transform-exception #f)
(define g-name-transform-exception? #f)
(define g-name-transform-exception-add #f)
(define g-name-transform-exception-remove #f)
(define g-name-transform-exception-reset #f)

(let ((%g-name-transform-exception '(("GObject" . "gobject"))))

  (set! g-name-transform-exception
        (lambda ()
          %g-name-transform-exception))

  (set! g-name-transform-exception?
        (lambda (key)
          (assoc-ref %g-name-transform-exception key)))

  (set! g-name-transform-exception-add
        (lambda (key value)
          (set! %g-name-transform-exception
                (assoc-set! %g-name-transform-exception key value))))

  (set! g-name-transform-exception-remove
        (lambda (key)
          (unless (string=? key "GObject")
            (set! %g-name-transform-exception
                  (assoc-remove! %g-name-transform-exception key)))))

  (set! g-name-transform-exception-reset
        (lambda ()
          (set! %g-name-transform-exception
                '(("GObject" . "gobject"))))))


;;;
;;; studly caps expand token exception
;;;

(define g-studly-caps-expand-token-exception #f)
(define g-studly-caps-expand-token-exception? #f)
(define g-studly-caps-expand-token-exception-add #f)
(define g-studly-caps-expand-token-exception-remove #f)
(define g-studly-caps-expand-token-exception-reset #f)

(let ((%g-studly-caps-expand-token-exception '(("WebKit" . "webkit"))))

  (set! g-studly-caps-expand-token-exception
        (lambda ()
          %g-studly-caps-expand-token-exception))

  (set! g-studly-caps-expand-token-exception?
        (lambda (key)
          (assoc-ref %g-studly-caps-expand-token-exception key)))

  (set! g-studly-caps-expand-token-exception-add
        (lambda (key value)
          (set! %g-studly-caps-expand-token-exception
                (assoc-set! %g-studly-caps-expand-token-exception key value))))

  (set! g-studly-caps-expand-token-exception-remove
        (lambda (key)
          (unless (string=? key "WebKit")
            (set! %g-studly-caps-expand-token-exception
                  (assoc-remove! %g-studly-caps-expand-token-exception key)))))

  (set! g-studly-caps-expand-token-exception-reset
        (lambda ()
          (set! %g-studly-caps-expand-token-exception
                '(("WebKit" . "webkit"))))))


;;;
;;; short name transform exception
;;;

(define g-short-name-transform-exception #f)
(define g-short-name-transform-exception? #f)

(let ((%g-short-name-transform-exception
       '(("GObject" . "g-object"))))

  (set! g-short-name-transform-exception
        (lambda ()
          %g-short-name-transform-exception))

  (set! g-short-name-transform-exception?
        (lambda (name)
          (assoc-ref %g-short-name-transform-exception name))))


;;;
;;; strip boolean result
;;;

(define gi-strip-boolean-result #f)
(define gi-strip-boolean-result? #f)
(define strip-boolean-result-add #f)
(define strip-boolean-result-remove #f)
(define gi-strip-boolean-result-reset #f)

(let ((%gi-strip-boolean-result '()))

  (set! gi-strip-boolean-result
        (lambda ()
          %gi-strip-boolean-result))

  (set! gi-strip-boolean-result?
        (lambda (name)
          (memq name %gi-strip-boolean-result)))

  (set! strip-boolean-result-add
        (lambda (names)
          (set! %gi-strip-boolean-result
                (apply lset-adjoin eq?
                       %gi-strip-boolean-result
                       names))))

  (set! strip-boolean-result-remove
        (lambda (names)
          (set! %gi-strip-boolean-result
                (lset-difference eq?
                                 %gi-strip-boolean-result
                                 names))))

  (set! gi-strip-boolean-result-reset
        (lambda ()
          (set! %gi-strip-boolean-result '()))))

(define-syntax gi-strip-boolean-result-add
  (syntax-rules ()
    ((gi-strip-boolean-result-add name ...)
     (strip-boolean-result-add '(name ...)))))

(define-syntax gi-strip-boolean-result-remove
  (syntax-rules ()
    ((gi-strip-boolean-result-remove name ...)
     (strip-boolean-result-remove '(name ...)))))


;;;
;;; short name skip
;;;

(define gi-method-short-name-skip #f)
(define gi-method-short-name-skip? #f)
(define gi-method-short-name-skip-all #f)
(define method-short-name-skip-add #f)
(define method-short-name-skip-remove #f)
(define gi-method-short-name-skip-reset #f)

(let ((%gi-method-short-name-skip '()))

  (set! gi-method-short-name-skip
        (lambda ()
          %gi-method-short-name-skip))

  (set! gi-method-short-name-skip?
        (lambda (name)
          (or (eq? %gi-method-short-name-skip 'all)
              (memq name %gi-method-short-name-skip))))

  (set! gi-method-short-name-skip-all
        (lambda ()
          (set! %gi-method-short-name-skip 'all)))

  (set! method-short-name-skip-add
        (lambda (names)
          (if (eq? %gi-method-short-name-skip 'all)
              (values)
              (set! %gi-method-short-name-skip
                    (apply lset-adjoin eq?
                           %gi-method-short-name-skip
                           names)))))

  (set! method-short-name-skip-remove
        (lambda (names)
          (if (eq? %gi-method-short-name-skip 'all)
              (values)
              (set! %gi-method-short-name-skip
                    (lset-difference eq?
                                     %gi-method-short-name-skip
                                     names)))))

  (set! gi-method-short-name-skip-reset
        (lambda ()
          (set! %gi-method-short-name-skip '()))))

(define-syntax gi-method-short-name-skip-add
  (syntax-rules ()
    ((gi-method-short-name-skip-add name ...)
     (method-short-name-skip-add '(name ...)))))

(define-syntax gi-method-short-name-skip-remove
  (syntax-rules ()
    ((gi-method-short-name-skip-remove name ...)
     (method-short-name-skip-remove '(name ...)))))


;;;
;;; syntax name protect
;;;

(define syntax-name-protect-prefix #f)
(define syntax-name-protect-prefix-set #f)
(define syntax-name-protect-prefix-reset #f)

(let ((%syntax-name-protect-prefix #f))

  (set! syntax-name-protect-prefix
        (lambda ()
          %syntax-name-protect-prefix))

  (set! syntax-name-protect-prefix-set
        (lambda (value)
          (set! %syntax-name-protect-prefix value)))

  (set! syntax-name-protect-prefix-reset
        (lambda ()
          (set! %syntax-name-protect-prefix #f))))

(define syntax-name-protect-postfix #f)
(define syntax-name-protect-postfix-set #f)
(define syntax-name-protect-postfix-reset #f)

(let ((%syntax-name-protect-postfix '_))

  (set! syntax-name-protect-postfix
        (lambda ()
          %syntax-name-protect-postfix))

  (set! syntax-name-protect-postfix-set
        (lambda (value)
          (set! %syntax-name-protect-postfix value)))

  (set! syntax-name-protect-postfix-reset
        (lambda ()
          (set! %syntax-name-protect-postfix '_))))

(define syntax-name-protect-renamer #f)
(define syntax-name-protect-renamer-set #f)
(define syntax-name-protect-renamer-reset #f)

(let ((%syntax-name-protect-renamer #f))

  (set! syntax-name-protect-renamer
        (lambda ()
          %syntax-name-protect-renamer))

  (set! syntax-name-protect-renamer-set
        (lambda (value)
          (set! %syntax-name-protect-renamer value)))

  (set! syntax-name-protect-renamer-reset
        (lambda ()
          (set! %syntax-name-protect-renamer #f))))

(define (syntax-name-protect-reset)
  (syntax-name-protect-prefix-reset)
  (syntax-name-protect-postfix-reset)
  (syntax-name-protect-renamer-reset))
