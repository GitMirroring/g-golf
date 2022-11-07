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


(define-module (g-golf gi cache-others)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (system foreign)
  #:use-module (g-golf gobject boxed-types)

  #:export (;; instance cache
            %g-inst-cache
            g-inst-cache-ref
            g-inst-cache-set!
            g-inst-cache-show

            ;; boxed sa - scheme allocated - cache
            %g-boxed-sa-cache
            g-boxed-sa-cache-ref
            g-boxed-sa-cache-set!
            g-boxed-sa-cache-remove!
            g-boxed-sa-cache-show
            g-boxed-sa-guard

            ;; boxed ga - gobject allocated - cache
            %g-boxed-ga-cache
            g-boxed-ga-cache-ref
            g-boxed-ga-cache-set!
            g-boxed-ga-cache-remove!
            g-boxed-ga-cache-show
            g-boxed-ga-guard))


;;;
;;; The g-inst(ance) cache
;;;


(define %g-inst-cache #f)
(define g-inst-cache-ref #f)
(define g-inst-cache-set! #f)
(define g-inst-cache-show #f)

(eval-when (expand load eval)
  (let* ((%g-inst-cache-default-size 1013))

    (set! %g-inst-cache
          (make-weak-value-hash-table %g-inst-cache-default-size))

    (set! g-inst-cache-ref
          (lambda (g-inst)
            (hashq-ref %g-inst-cache
                       (pointer-address g-inst))))

    (set! g-inst-cache-set!
          (lambda (g-inst inst)
            (hashq-set! %g-inst-cache
                        (pointer-address g-inst)
                        inst)))

    (set! g-inst-cache-show
          (lambda ()
            (hash-for-each (lambda (key value)
                             (%dimfi key value))
                           %g-inst-cache)))))


#;(define (g-inst-cache-for-each proc)
  (hash-for-each proc
                 %g-inst-cache))

#;(define* (g-inst-cache-show #:optional
                            (port (current-output-port)))
  (let ((n-entry (hash-count (const #t) %g-inst-cache)))
    (case n-entry
      ((0)
       (display "The g-inst cache is empty\n" port))
      (else
       (letrec ((show (lambda (key value)
                        (format port "  ~S  -  ~S~%"
                                (!g-inst value)
                                value))))
         (format port "The g-inst cache has ~A entry(ies):~%"
                 n-entry)
         (g-inst-cache-for-each show))))))


;;;
;;; The g-boxed(instance) scheme allocated cache
;;;

(define %dimfi
  (@ (g-golf support utils) dimfi))

(define %g-boxed-sa-cache #f)
(define g-boxed-sa-cache-ref #f)
(define g-boxed-sa-cache-set! #f)
(define g-boxed-sa-cache-remove! #f)
(define g-boxed-sa-cache-show #f)

(eval-when (expand load eval)
  (let* ((%g-boxed-sa-cache-default-size 1013)
         (g-boxed-sa-cache
          (make-weak-value-hash-table %g-boxed-sa-cache-default-size)))

    (set! %g-boxed-sa-cache
          (lambda () g-boxed-sa-cache))

    (set! g-boxed-sa-cache-ref
          (lambda (ptr)
            (hashq-ref g-boxed-sa-cache ptr)))

    (set! g-boxed-sa-cache-set!
          (lambda (ptr bv)
            (hashq-set! g-boxed-sa-cache ptr bv)))

    (set! g-boxed-sa-cache-remove!
          (lambda (ptr)
            (hashq-remove! g-boxed-sa-cache ptr)))

    (set! g-boxed-sa-cache-show
          (lambda ()
            (hash-for-each (lambda (key value)
                             (%dimfi key value))
                           g-boxed-sa-cache)))))


;;;
;;; g-boxed-sa-guard
;;;

(define-syntax make-g-boxed-sa-guard
  (syntax-rules ()
    ((make-g-boxed-sa-guard)
     (let ((guardian (make-guardian)))
       (add-hook! after-gc-hook
                  (lambda ()
                    #;(%dimfi guardian)
                    (let loop ()
                      (let ((ptr (guardian)))
                        (when ptr
                          #;(%dimfi "  cleaning" ptr)
                          (loop))))))
       (lambda (ptr bv)
         (g-boxed-sa-cache-set! ptr bv)
         (guardian ptr)
         ptr)))))

(define g-boxed-sa-guard (make-g-boxed-sa-guard))


;;;
;;; The g-boxed(instance) gobject allocated cache
;;;

;; in this case, we need to use a normal hash table, because when a
;; guardian returns a pointer, as part of an after-gc-hook procedure, a
;; weak hash table would already have cleared the entry, and unlike for
;; the other caches, we need to retreive the g-type of the (opaque)
;; boxedtype pointer.

;; a consequence of the above, is that we can't hold a reference to the
;; ffi pointer, otherwise it would never become unreachable ... and
;; hence, we specifically use the pointer address as the key.

(define %g-boxed-ga-cache #f)
(define g-boxed-ga-cache-ref #f)
(define g-boxed-ga-cache-set! #f)
(define g-boxed-ga-cache-remove! #f)
(define g-boxed-ga-cache-show #f)

(eval-when (expand load eval)
  (let* ((%g-boxed-ga-cache-default-size 1013)
         (g-boxed-ga-cache
          (make-weak-value-hash-table %g-boxed-ga-cache-default-size)))

    (set! %g-boxed-ga-cache
          (lambda () g-boxed-ga-cache))

    (set! g-boxed-ga-cache-ref
          (lambda (ptr)
            (hashq-ref g-boxed-ga-cache ptr)))

    (set! g-boxed-ga-cache-set!
          (lambda (ptr bv)
            (hashq-set! g-boxed-ga-cache ptr bv)))

    (set! g-boxed-ga-cache-remove!
          (lambda (ptr)
            (hashq-remove! g-boxed-ga-cache ptr)))

    (set! g-boxed-ga-cache-show
          (lambda ()
            (hash-for-each (lambda (key value)
                             (%dimfi key value))
                           g-boxed-ga-cache)))))


;;;
;;; g-boxed-ga-guard
;;;

(define-syntax make-g-boxed-ga-guard
  (syntax-rules ()
    ((make-g-boxed-ga-guard)
     (let ((guardian (make-guardian)))
       (add-hook! after-gc-hook
                  (lambda ()
                    #;(%dimfi guardian)
                    (let loop ()
                      (let ((ptr (guardian)))
                        (when ptr
                          #;(%dimfi "  cleaning" ptr)
                          (let ((g-type (g-boxed-ga-cache-ref ptr)))
                            (g-boxed-ga-cache-remove! ptr)
                            (g-boxed-free g-type ptr)
                            (loop)))))))
       (lambda (ptr g-type)
         (g-boxed-ga-cache-set! ptr g-type)
         (guardian ptr)
         ptr)))))

(define g-boxed-ga-guard (make-g-boxed-ga-guard))
