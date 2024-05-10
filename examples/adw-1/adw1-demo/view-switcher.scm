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


(define-module (adw1-demo view-switcher)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw1-demo view-switcher-demo-dialog)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-view-switcher>))


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


(define-class <adw-demo-page-view-switcher> (<adw-bin>)
  ;; slots
  (view-switcher-button #:child-id "view-switcher-button"
                          #:accessor !view-switcher-button)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/view-switcher.ui")
  #:child-ids '("view-switcher-button"))


(define-method (initialize (self <adw-demo-page-view-switcher>) initargs)
  (next-method)

  (connect (!view-switcher-button self)
           "clicked"
           (lambda (b)
             (let ((view-switcher-demo-dialog
                    (make <adw-view-switcher-demo-dialog>)))
               (present view-switcher-demo-dialog self)))))
