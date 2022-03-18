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

  #:export (gi-strip-boolean-result
            gi-strip-boolean-result?
            gi-strip-boolean-result-add
            gi-strip-boolean-result-remove
            gi-strip-boolean-result-reset

            gi-method-short-name-skip
            gi-method-short-name-skip?
            gi-method-short-name-skip-all
            gi-method-short-name-skip-add
            gi-method-short-name-skip-remove
            gi-method-short-name-skip-reset))


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
                (append names
                        %gi-strip-boolean-result))))

  (set! strip-boolean-result-remove
        (lambda (names)
          (set! %gi-strip-boolean-result
                (lset-difference eq? %gi-strip-boolean-result names))))

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
                    (append names
                            %gi-method-short-name-skip)))))

  (set! method-short-name-skip-remove
        (lambda (names)
          (if (eq? %gi-method-short-name-skip 'all)
              (values)
              (set! %gi-method-short-name-skip
                    (lset-difference eq? %gi-method-short-name-skip names)))))

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
