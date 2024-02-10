;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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


(define-module (g-golf support ffi)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (srfi srfi-4)
  #:use-module (g-golf support libg-golf)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf support utils)

  #:export (ffi-arg->scm
            ffi-arg-boolean->scm
            ffi-arg-int8->scm
            ffi-arg-uint8->scm
            ffi-arg-int16->scm
            ffi-arg-uint16->scm
            ffi-arg-int16->scm
            ffi-arg-uint16->scm
            ffi-arg-int32->scm
            ffi-arg-uint32->scm
            ffi-arg-int64->scm
            ffi-arg-uint64->scm
            ffi-arg-float->scm
            ffi-arg-double->scm
            ffi-arg-gtype->scm
            ffi-arg-string->scm
            ffi-arg-pointer->scm

            ffi-cif-size
            ffi-type-size
            ffi-prep-cif
            #;ffi-pack-double))


(define (ffi-arg->scm ffi-arg type-tag is-pointer? is-enum?)
  (case type-tag
    ((boolean)
     (ffi-arg-boolean->scm ffi-arg))
    ((int8)
     (ffi-arg-int8->scm ffi-arg))
    ((uint8)
     (ffi-arg-uint8->scm ffi-arg))
    ((int16)
     (ffi-arg-int16->scm ffi-arg))
    ((uint16)
     (ffi-arg-uint16->scm ffi-arg))
    ((int32)
     (ffi-arg-int32->scm ffi-arg))
    ((uint32
      unichar)
     (ffi-arg-uint32->scm ffi-arg))
    ((int64)
     (ffi-arg-int64->scm ffi-arg))
    ((uint64)
     (ffi-arg-uint64->scm ffi-arg))
    ((float)
     (ffi-arg-float->scm ffi-arg))
    ((double)
     (ffi-arg-double->scm ffi-arg))
    ((gtype)
     (ffi-arg-gtype->scm ffi-arg))
    ((utf8
      filename)
     (ffi-arg-string->scm ffi-arg))
    ((array
      glist
      gslist
      ghash
      error)
     (ffi-arg-pointer->scm ffi-arg))
    ((interface)
     ;; Needs to handle enums specially:
     ;; https://bugzilla.gnome.org/show_bug.cgi?id=665150
     (if is-enum?
         (ffi-arg-int32->scm ffi-arg)
         (ffi-arg-pointer->scm ffi-arg)))
    ((void)
     (if is-pointer?
         (ffi-arg-pointer->scm ffi-arg)
         'void))
    (else
     (scm-error 'failed #f
                "Unimplemented ffi-arg->scm type-tag: ~A"
                (list type-tag) #f))))

(define (ffi-arg-boolean->scm ffi-arg)
  (let* ((size (sizeof unsigned-int))
         (bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr size)))
    (gi->scm (case size
               ((4)
                (u32vector-ref bv 0))
               ((8)
                (u64vector-ref bv 0))
               (else
                (error "what machine is this?")))
             'boolean)))

(define (ffi-arg-int8->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof int8))))
    (s8vector-ref bv 0)))

(define (ffi-arg-uint8->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof uint8))))
    (u8vector-ref bv 0)))

(define (ffi-arg-int16->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof int16))))
    (s16vector-ref bv 0)))

(define (ffi-arg-uint16->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof uint16))))
    (u16vector-ref bv 0)))

(define (ffi-arg-int32->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof int32))))
    (s32vector-ref bv 0)))

(define (ffi-arg-uint32->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof uint32))))
    (u32vector-ref bv 0)))

(define (ffi-arg-int64->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof int64))))
    (s64vector-ref bv 0)))

(define (ffi-arg-uint64->scm ffi-arg)
  (let* ((bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr (sizeof uint64))))
    (u64vector-ref bv 0)))

(define (ffi-arg-float->scm ffi-arg)
  (let* ((size (sizeof float))
         (bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr size)))
    (case size
      ((4)
       (f32vector-ref bv 0))
      ((8)
       (f64vector-ref bv 0))
      (else
       (error "what machine is this?")))))

(define (ffi-arg-double->scm ffi-arg)
  (let* ((size (sizeof double))
         (bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr size)))
    (case size
      ((4)
       (f32vector-ref bv 0))
      ((8)
       (f64vector-ref bv 0))
      (else
       (error "what machine is this?")))))

(define (ffi-arg-gtype->scm ffi-arg)
  (let* ((size (sizeof size_t))
         (bv-ptr (dereference-pointer ffi-arg))
         (bv (pointer->bytevector bv-ptr size)))
    (case size
      ((4)
       (u32vector-ref bv 0))
      ((8)
       (u64vector-ref bv 0))
      (else
       (error "what machine is this?")))))

(define (ffi-arg-string->scm ffi-arg)
  (gi->scm (dereference-pointer ffi-arg) 'string))

(define (ffi-arg-pointer->scm ffi-arg)
  (gi->scm (dereference-pointer ffi-arg) 'pointer))


;;;
;;; From libg-golf
;;;

(define ffi-cif-size gg_ffi_cif_size)

(define ffi-type-size gg_ffi_type_size)

(define (ffi-prep-cif cif n-args r-type a-types)
  (let ((ffi-status (gg_ffi_prep_cif cif n-args r-type a-types)))
    (unless (= ffi-status 0)
      (scm-error 'failed #f "ffi_prep_cif failed: ~A"
                 (list ffi-status) #f))))

#;(define (ffi-pack-double ffi-arg)
  (gg_ffi_pack_double ffi-arg))
