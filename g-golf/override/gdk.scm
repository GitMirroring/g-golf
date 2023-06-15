;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2021 - 2023
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


(define-module (g-golf override gdk)
  #:export (gdk-clipboard-set-ov
            gdk-content-provider-get-value-ov))


(define (gdk-clipboard-set-ov proc)
  (values
   #f
   `(lambda (clipboard value)
      (let* ((i-func ,proc)
             (g-type (scm->g-type value))
             (g-value (g-value-init g-type)))
        (g-value-set! g-value
                      (scm->g-property g-type value))
        (i-func clipboard g-value)
        (g-value-unset g-value)
        (values)))
   '(0 1)))


(define (gdk-content-provider-get-value-ov proc)
  (values
   #f
   `(lambda (content-provider)
      (let* ((i-func ,proc)
             (content-formats (ref-formats content-provider))
             (g-types (gdk-content-formats-get-gtypes content-formats))
             (g-type (car g-types))
             (g-value (g-value-init g-type))
             (dum (i-func content-provider g-value))
             (value (g-value->scm g-value g-type)))
        (g-boxed-free (g-param-spec-type
                       (g-object-class-find-property
                        (!g-class (class-of content-provider))
                        "formats"))
                      content-formats)
        (g-value-unset g-value)
        value))
   '(0)))
