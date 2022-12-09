;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2022
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


(define-module (g-golf support bytevector)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)

  #:export (bv-ptr-ref
            bv-ptr-set!

            make-gtypevector
            gtypevector-ref
            gtypevector-set!
            gtypevector->list
            list->gtypevector

            make-ulongvector
            ulongvector-ref
            ulongvector-set!
            ulongvector->list
            list->ulongvector))


(define %align
  (@@ (system foreign) align))

(define %bv-ptr-ref
  (@@ (system foreign) bytevector-pointer-ref))

(define %bv-ptr-set!
  (@@ (system foreign) bytevector-pointer-set!))

(define (bv-ptr-ref foreign)
  (let* ((size (sizeof '*))
         (bv (pointer->bytevector foreign size))
         (offset (%align 0 (alignof '*))))
    (%bv-ptr-ref bv offset)))

(define (bv-ptr-set! foreign val)
  (let* ((size (sizeof '*))
         (bv (pointer->bytevector foreign size))
         (offset (%align 0 (alignof '*))))
    (%bv-ptr-set! bv offset val)))


;;;
;;; Support for GLib and C types that varies in length
;;; depending on the platform
;;;

;;;
;;; GType
;;;

(define make-gtypevector
  (case (sizeof size_t)
    ((8) (lambda (n . value)
           (match value
             (() (make-u64vector n))
             ((val) (make-u64vector n val)))))
    ((4) (lambda (n . value)
           (match value
             (() (make-u32vector n))
             ((val) (make-u32vector n val)))))
    (else (error "what machine is this?"))))

(define gtypevector-ref
  (case (sizeof size_t)
    ((8) (lambda (bv offset)
           (u64vector-ref bv offset)))
    ((4) (lambda (bv offset)
           (u32vector-ref bv offset)))
    (else (error "what machine is this?"))))

(define gtypevector-set!
  (case (sizeof size_t)
    ((8) (lambda (bv offset value)
           (u64vector-set! bv offset value)))
    ((4) (lambda (bv offset value)
           (u32vector-set! bv offset value)))
    (else (error "what machine is this?"))))

(define gtypevector->list
  (case (sizeof size_t)
    ((8) (lambda (bv)
           (u64vector->list bv)))
    ((4) (lambda (bv)
           (u32vector->list bv)))
    (else (error "what machine is this?"))))

(define list->gtypevector
  (case (sizeof size_t)
    ((8) (lambda (lst)
           (list->u64vector lst)))
    ((4) (lambda (lst)
           (list->u32vector lst)))
    (else (error "what machine is this?"))))


;;;
;;; unsigned-long
;;;

(define make-ulongvector
  (case (sizeof unsigned-long)
    ((8) (lambda (n . value)
           (match value
             (() (make-u64vector n))
             ((val) (make-u64vector n val)))))
    ((4) (lambda (n . value)
           (match value
             (() (make-u32vector n))
             ((val) (make-u32vector n val)))))
    (else (error "what machine is this?"))))

(define ulongvector-ref
  (case (sizeof unsigned-long)
    ((8) (lambda (bv offset)
           (u64vector-ref bv offset)))
    ((4) (lambda (bv offset)
           (u32vector-ref bv offset)))
    (else (error "what machine is this?"))))

(define ulongvector-set!
  (case (sizeof unsigned-long)
    ((8) (lambda (bv offset value)
           (u64vector-set! bv offset value)))
    ((4) (lambda (bv offset value)
           (u32vector-set! bv offset value)))
    (else (error "what machine is this?"))))

(define ulongvector->list
  (case (sizeof unsigned-long)
    ((8) (lambda (bv)
           (u64vector->list bv)))
    ((4) (lambda (bv)
           (u32vector->list bv)))
    (else (error "what machine is this?"))))

(define list->ulongvector
  (case (sizeof unsigned-long)
    ((8) (lambda (lst)
           (list->u64vector lst)))
    ((4) (lambda (lst)
           (list->u32vector lst)))
    (else (error "what machine is this?"))))
