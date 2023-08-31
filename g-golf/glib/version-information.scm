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


(define-module (g-golf glib version-information)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (srfi srfi-4)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf init)

  #:export (glib-get-major-version
            glib-get-minor-version
            glib-get-micro-version))


;;;
;;; 
;;;

(define (glib-get-major-version)
  (let* ((bv-ptr (glib_major_version_ptr))
         (bv (pointer->bytevector bv-ptr (sizeof uint32))))
    (u32vector-ref bv 0)))

(define (glib-get-minor-version)
  (let* ((bv-ptr (glib_minor_version_ptr))
         (bv (pointer->bytevector bv-ptr (sizeof uint32))))
    (u32vector-ref bv 0)))

(define (glib-get-micro-version)
  (let* ((bv-ptr (glib_micro_version_ptr))
         (bv (pointer->bytevector bv-ptr (sizeof uint32))))
    (u32vector-ref bv 0)))


;;;
;;; Glib Bindings
;;;

(define (glib_major_version_ptr)
  (dynamic-pointer "glib_major_version"
                   (dynamic-link "libglib-2.0")))

(define (glib_minor_version_ptr)
  (dynamic-pointer "glib_minor_version"
                   (dynamic-link "libglib-2.0")))

(define (glib_micro_version_ptr)
  (dynamic-pointer "glib_micro_version"
                   (dynamic-link "libglib-2.0")))
