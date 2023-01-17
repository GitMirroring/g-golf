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
  #:use-module (g-golf support libg-golf)

  #:export (ffi-cif-size
            ffi-type-size
            ffi-prep-cif
            ffi-pack-double))


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

(define (ffi-pack-double ffi-arg)
  (gg_ffi_pack_double ffi-arg))
