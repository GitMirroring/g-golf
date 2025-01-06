;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2025
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


(define-module (g-golf glib type-conversion)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (g-golf init)
  #:use-module (g-golf support libg-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gint-to-pointer
            guint-to-pointer))


;;;
;;; Glib Low level API
;;;

;; from libg-golf
(define (gint-to-pointer i)
  (gint_to_pointer i))

;; from libg-golf
(define (guint-to-pointer i)
  (guint_to_pointer i))


;;;
;;; Glib Bindings
;;;
