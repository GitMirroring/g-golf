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


(define-module (adw1-demo split-views)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw1-demo split-views-navigation-dialog)
  #:use-module (adw1-demo split-views-overlay-dialog)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-split-views>))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Root"
        "Button"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Bin"
        "Dialog")))


(define-class <adw-demo-page-split-views> (<adw-bin>)
  ;; slots
  (navigation-split-view-bt #:child-id "navigation-split-view-bt"
                            #:accessor !navigation-split-view-bt)
  (overlay-split-view-bt #:child-id "overlay-split-view-bt"
                         #:accessor !overlay-split-view-bt)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/split-views.ui")
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
