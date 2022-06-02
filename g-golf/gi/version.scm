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


(define-module (g-golf gi version)
  #:use-module (system foreign)
  #:use-module (g-golf init)

  #:export (gi-check-version
            gi-version
            gi-effective-version
            gi-major-version
            gi-minor-version
            gi-micro-version))


;;;
;;; Low level API
;;;

(define (gi-check-version major minor micro)
  (let ((gi-major (gi-get-major-version))
        (gi-minor (gi-get-minor-version))
        (gi-micro (gi-get-micro-version)))
    (or (> gi-major major)
        (and (= gi-major major)
             (> gi-minor minor))
        (and (= gi-major major)
             (= gi-minor minor)
             (>= gi-micro micro)))))

(define (gi-version)
  (simple-format #f "~A.~A.~A"
                 (gi-get-major-version)
                 (gi-get-minor-version)
                 (gi-get-micro-version)))

(define (gi-effective-version)
  (simple-format #f "~A.~A"
                 (gi-get-major-version)
                 (gi-get-minor-version)))

(define* (gi-major-version #:optional (as-integer? #f))
  (if as-integer?
      (gi-get-major-version)
      (number->string (gi-get-major-version))))

(define* (gi-minor-version #:optional (as-integer? #f))
  (if as-integer?
      (gi-get-minor-version)
      (number->string (gi-get-minor-version))))

(define* (gi-micro-version #:optional (as-integer? #f))
  (if as-integer?
      (gi-get-micro-version)
      (number->string (gi-get-micro-version))))

(define (gi-get-major-version)
  (gi_get_major_version))

(define (gi-get-minor-version)
  (gi_get_minor_version))

(define (gi-get-micro-version)
  (gi_get_micro_version))


;;;
;;; GI Bindings
;;;

(define gi_get_major_version
  (pointer->procedure int
                      (dynamic-func "gi_get_major_version"
				    %libgirepository)
                      (list)))

(define gi_get_minor_version
  (pointer->procedure int
                      (dynamic-func "gi_get_minor_version"
				    %libgirepository)
                      (list)))

(define gi_get_micro_version
  (pointer->procedure int
                      (dynamic-func "gi_get_micro_version"
				    %libgirepository)
                      (list)))
