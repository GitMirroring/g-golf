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


(define-module (pages split-views split-views)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages split-views split-views-navigation-dialog)
  #:use-module (pages split-views split-views-overlay-dialog)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-split-views>))


#;(g-export )


(define-class <adw-demo-page-split-views> (<adw-bin>)
  ;; slots
  (navigation-split-view-bt #:child-id "navigation-split-view-bt"
                            #:accessor !navigation-split-view-bt)
  (overlay-split-view-bt #:child-id "overlay-split-view-bt"
                         #:accessor !overlay-split-view-bt)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/split-views/split-views-ui.ui")
  #:child-ids '("navigation-split-view-bt"
                "overlay-split-view-bt"))


(define-method (initialize (self <adw-demo-page-split-views>) initargs)
  (next-method)

  (connect (!navigation-split-view-bt self)
           "clicked"
           (lambda (b)
             (let ((split-views-navigation-dialog
                    (make <adw-split-views-navigation-dialog>)))
               (present split-views-navigation-dialog self))))

  (connect (!overlay-split-view-bt self)
           "clicked"
           (lambda (b)
             (let ((split-views-overlay-dialog
                    (make <adw-split-views-overlay-dialog>)))
               (present split-views-overlay-dialog self)))))
