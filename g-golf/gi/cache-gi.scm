;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2018 - 2022
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


(define-module (g-golf gi cache-gi)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (system foreign)
  #:use-module (g-golf gobject boxed-types)

  #:export (gi-cache
            gi-cache-ref
            gi-cache-set!
            gi-cache-remove!
            gi-cache-find
            gi-cache-show))


(define %dimfi
  (@ (g-golf support utils) dimfi))

(define gi-cache #f)
(define gi-cache-ref #f)
(define gi-cache-set! #f)
(define gi-cache-remove! #f)
(define gi-cache-find #f)


(eval-when (expand load eval)
  (letrec* ((enum-cache (make-hash-table 1013))
            (function-cache (make-hash-table 5591))
            (struct-cache (make-hash-table 1013))
            (boxed-cache (make-hash-table 1013))
            (union-cache (make-hash-table 1013))
            (flags-cache (make-hash-table 1013))
            (%gi-cache (lambda (m-key)
                         (case m-key
                           ((enum) enum-cache)
                           ((function) function-cache)
                           ((struct) struct-cache)
                           ((boxed) boxed-cache)
                           ((union) union-cache)
                           ((flags) flags-cache)
                           (else
                            (scm-error 'invalid-cache-name #f "Invalid cache name: ~S"
                                       (list m-key) #f))))))

    (set! gi-cache %gi-cache)

    (set! gi-cache-ref
          (lambda (m-key s-key)
            ;; m-key: main key; s-key: secondary key
            (hashq-ref (%gi-cache m-key) s-key)))

    (set! gi-cache-set!
          (lambda (m-key s-key val)
            ;; m-key: main key; s-key: secondary key
            (hashq-set! (%gi-cache m-key) s-key val)))

    (set! gi-cache-remove!
          (lambda (m-key s-key)
            ;; m-key: main key; s-key: secondary key
            (hashq-remove! (%gi-cache m-key) s-key)))

    (set! gi-cache-find
          (lambda (m-key lookup)
            (let ((lookup-str (if (string? lookup)
                                  lookup
                                  (symbol->string lookup))))
              (hash-fold (lambda (key val results)
                           (let ((key-str (symbol->string key)))
                             (if (string-contains key-str lookup-str)
                                 (cons (cons key val) results)
                                 results)))
                         '()
                         (%gi-cache m-key)))))

    (set! gi-cache-show
          (lambda (m-key)
            (hash-for-each (lambda (key value)
                             (%dimfi key value))
                (%gi-cache m-key))))))
