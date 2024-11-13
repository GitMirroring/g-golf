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

;;; Code:


(define-module (pages animations animations-scene)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages animations animations-layout)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<animation-scene>))


#;(g-export )


(define-class <animation-scene> (<adw-bin>)
  ;; class options
  #:layout-manager <animation-layout>)

(define-method (initialize (self <animation-scene>) initargs)
  (next-method)
  (let ((animation-sample (make <adw-bin>
                            #:halign 'center
                            #:valign 'center
                            #:name "animation-sample")))
    (set-child self animation-sample)))


;;;
;;; callback
;;;


;;;
;;; utils
;;;
