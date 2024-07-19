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


(define-module (pages navigation-view navigation-view)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages navigation-view navigation-view-demo-dialog)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-navigation-view>))


#;(g-export )


(define-class <adw-demo-page-navigation-view> (<adw-bin>)
  ;; slots
  (navigation-view-button #:child-id "navigation-view-button"
                          #:accessor !navigation-view-button)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/navigation-view/navigation-view-ui.ui")
  #:child-ids '("navigation-view-button"))


(define-method (initialize (self <adw-demo-page-navigation-view>) initargs)
  (next-method)

  (connect (!navigation-view-button self)
           "clicked"
           (lambda (b)
             (let ((navigation-view-demo-dialog
                    (make <adw-navigation-view-demo-dialog>)))
               (present navigation-view-demo-dialog self)))))
