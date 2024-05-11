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


(define-module (adw1-demo clamp)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-clamp>))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("ClosureExpression"
        "Adjustment"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Bin"
        "Clamp"
        "PreferencesGroup"
        "StatusPage"
        "SpinRow"
        "ComboRow"
        "EnumListModel"
        "EnumListItem"
        "LengthUnit")))


(define-class <adw-demo-page-clamp> (<adw-bin>)
  ;; slot(s)
  ;; child-id slot(s)
  (clamp #:child-id "clamp" #:accessor !clamp)
  (maximum-size-adjustment #:child-id "maximum-size-adjustment"
                           #:accessor !maximum-size-adjustment)
  (tightening-threshold-adjustment #:child-id "tightening-threshold-adjustment"
                                   #:accessor !tightening-threshold-adjustment)
  (unit-row #:child-id "unit-row" #:accessor !unit-row)  
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/clamp.ui")
  #:child-ids '("clamp"
                "maximum-size-adjustment"
                "tightening-threshold-adjustment"
                "unit-row"))

(define-method (initialize (self <adw-demo-page-clamp>) initargs)
  (next-method)

  #;(set-expressions self)
  (bind-properties self))


;;;
;;; set expressions
;;;


;;;
;;; bind properties
;;;

(define (bind-properties clamp-page)
  (bind-property (!maximum-size-adjustment clamp-page)
                 "value"
                 (!clamp clamp-page)
                 "maximum-size"
                 '(sync-create))

  (bind-property (!tightening-threshold-adjustment clamp-page)
                 "value"
                 (!clamp clamp-page)
                 "tightening-threshold"
                 '(sync-create))

  (bind-property (!unit-row clamp-page)
                 "selected"
                 (!clamp clamp-page)
                 "unit"
                 '(sync-create)))


;;;
;;; notify callback
;;;


;;;
;;; utils
;;;

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))

