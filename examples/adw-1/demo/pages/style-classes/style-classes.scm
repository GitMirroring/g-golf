;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023, 2024
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


(define-module (pages style-classes style-classes)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages style-classes style-classes-demo-dialog)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-style-classes>))


#;(g-export )


(define-class <adw-demo-page-style-classes> (<adw-bin>)
  ;; slots
  (style-classes-button #:child-id "style-classes-button"
                        #:accessor !style-classes-button)
  ;; class options
  #:template (string-append  %adw-demo-path
                            "/pages/style-classes/style-classes-ui.ui")
  #:child-ids '("style-classes-button"))


(define-method (initialize (self <adw-demo-page-style-classes>) initargs)
  (next-method)

  (connect (!style-classes-button self)
           "clicked"
           (lambda (b)
             (let ((style-classes-demo-dialog
                    (make <adw-style-classes-demo-dialog>)))
               (present style-classes-demo-dialog self)))))
