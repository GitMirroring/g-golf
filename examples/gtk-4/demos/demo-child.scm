;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2024
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

;; /* This is a trivial child widget just for demo purposes.
;;  * It draws a 32x32 square in fixed color.
;;  */

;;; Code:


(define-module (demos demo-child)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<demo-child>))


#;(g-export !color)


(define-class <demo-child> (<gtk-widget>)
  (color #:accessor !color #:init-keyword #:color))

(define-method (initialize (self <demo-child>) initargs)
  (let ((color (or (get-keyword #:color initargs #f)
                   (scm-error 'missing-arg #f
                              "Initialize <demo-child>, missing #:color"
                              '() #f))))
    (next-method)))

(define-vfunc (snapshot-vfunc (self <demo-child>) snapshot)
  (append-color snapshot
                (!color self)
                (graphene-rect-init (graphene-rect-alloc)
                                    0
                                    0
                                    (get-width self)
                                    (get-height self))))

(define-vfunc (measure-vfunc (self <demo-child>) orientation for-size)
  (values 32		;; minimum
          32 		;; natural
          nil		;; minimum-baseline
          nil))		;; natural-baseline
