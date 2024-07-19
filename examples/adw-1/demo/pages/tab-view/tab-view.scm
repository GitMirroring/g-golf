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


(define-module (pages tab-view tab-view)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages tab-view tab-view-demo-window)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-tab-view>))


#;(g-export )


(define-class <adw-demo-page-tab-view> (<adw-bin>)
  ;; slots
  (tab-view-button #:child-id "tab-view-button"
                   #:accessor !tab-view-button)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/tab-view/tab-view-ui.ui")
  #:child-ids '("tab-view-button"))


(define-method (initialize (self <adw-demo-page-tab-view>) initargs)
  (next-method)

  (connect (!tab-view-button self)
           "clicked"
           (lambda (b)
             (let ((tab-view-demo-window
                    (make <adw-tab-view-demo-window>)))
               (prepopulate tab-view-demo-window)
               (set-transient-for tab-view-demo-window (get-root self))
               (present tab-view-demo-window)))))
