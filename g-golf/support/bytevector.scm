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


(define-module (g-golf support bytevector)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)

  #:export (%align
            bv-ptr-ref
            bv-ptr-set!
            %readers
            %writers

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


;;;
;;; from (system foreign)
;;;

;; Guile 3.0.10 introduces read-c-struct and write-c-struct, here is an
;; excerpt of the manual for the read-c-struct definition:

;;   Unless cross-compiling, the field types are evaluated at
;;   macro-expansion time. This allows the resulting bytevector
;;   accessors and size/alignment computations to be completely
;;   inlined.

;; One of the consequence is that some of the internals i was refering
;; to, *readers*, *writers*, align ... are now part of the newly
;; introduced syntax machinery.

;; So, for the time being, i'll just take a copy of those, from 3.0.9 -
;; later, i'll update g-golf to take advantage of these new
;; read-c-struct and write-c-struct syntax.

(define (%align off alignment)
  (1+ (logior (1- off) (1- alignment))))

(define %bv-ptr-ref
  (case (sizeof '*)
    ((8) (lambda (bv offset)
           (make-pointer (bytevector-u64-native-ref bv offset))))
    ((4) (lambda (bv offset)
           (make-pointer (bytevector-u32-native-ref bv offset))))
    (else (error "what machine is this?"))))

(define %bv-ptr-set!
  (case (sizeof '*)
    ((8) (lambda (bv offset ptr)
           (bytevector-u64-native-set! bv offset (pointer-address ptr))))
    ((4) (lambda (bv offset ptr)
           (bytevector-u32-native-set! bv offset (pointer-address ptr))))
    (else (error "what machine is this?"))))

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

(define (writer-complex set size)
  (lambda (bv i val)
    (set bv i (real-part val))
    (set bv (+ i size) (imag-part val))))

(define (reader-complex ref size)
  (lambda (bv i)
    (make-rectangular
     (ref bv i)
     (ref bv (+ i size)))))

(define %writers
  `((,float . ,bytevector-ieee-single-native-set!)
    (,double . ,bytevector-ieee-double-native-set!)
    ,@(if (defined? 'complex-float)
          `((,complex-float
             . ,(writer-complex bytevector-ieee-single-native-set! (sizeof float)))
            (,complex-double
             . ,(writer-complex bytevector-ieee-double-native-set! (sizeof double))))
          '())
    (,int8 . ,bytevector-s8-set!)
    (,uint8 . ,bytevector-u8-set!)
    (,int16 . ,bytevector-s16-native-set!)
    (,uint16 . ,bytevector-u16-native-set!)
    (,int32 . ,bytevector-s32-native-set!)
    (,uint32 . ,bytevector-u32-native-set!)
    (,int64 . ,bytevector-s64-native-set!)
    (,uint64 . ,bytevector-u64-native-set!)
    (* . ,%bv-ptr-set!)))

(define %readers
  `((,float . ,bytevector-ieee-single-native-ref)
    (,double . ,bytevector-ieee-double-native-ref)
    ,@(if (defined? 'complex-float)
          `((,complex-float
             . ,(reader-complex bytevector-ieee-single-native-ref (sizeof float)))
            (,complex-double
             . ,(reader-complex bytevector-ieee-double-native-ref (sizeof double))))
          '())
    (,int8 . ,bytevector-s8-ref)
    (,uint8 . ,bytevector-u8-ref)
    (,int16 . ,bytevector-s16-native-ref)
    (,uint16 . ,bytevector-u16-native-ref)
    (,int32 . ,bytevector-s32-native-ref)
    (,uint32 . ,bytevector-u32-native-ref)
    (,int64 . ,bytevector-s64-native-ref)
    (,uint64 . ,bytevector-u64-native-ref)
    (* . ,%bv-ptr-ref)))



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
