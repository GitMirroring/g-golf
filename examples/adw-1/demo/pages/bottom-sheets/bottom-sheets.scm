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


(define-module (pages bottom-sheets bottom-sheets)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-bottom-sheets>))


#;(g-export )


(define-class <adw-demo-page-bottom-sheets> (<adw-bin>)
  ;; slot(s)
  ;; child-id slot(s)
  (header-bar #:child-id "header-bar" #:accessor !header-bar)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/bottom-sheets/bottom-sheets-ui.ui")
  #:child-ids '("header-bar"))


#;(define-method (initialize (self <adw-demo-page-bottom-sheets>) initargs)
  (next-method)
  (set-decoration-layout (!header-bar self) ""))
