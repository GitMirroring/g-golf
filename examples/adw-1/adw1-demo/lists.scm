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


(define-module (adw1-demo lists)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-lists>))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("ClosureExpression"
        "Adjustment"
        "Box"
        "Button"
        "License"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Bin"
        "Toast"
        "ToastOverlay"
        "Clamp"
        "PreferencesGroup"
        "StatusPage"
        "SpinRow"
        "ComboRow"
        "EntryRow"
        "ExpanderRow"
        "ButtonContent"
        "EnumListModel"
        "EnumListItem"
        "LengthUnit")))


(define-class <adw-demo-page-lists> (<adw-bin>)
  ;; slot(s)
  ;; child-id slot(s)
  (lists #:child-id "lists" #:accessor !lists)
  (entry-row-1 #:child-id "entry-row-1" #:accessor !entry-row-1)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/lists.ui")
  #:child-ids '("lists"
                "entry-row-1")
  #:g-signal `(add-toast	;; name
               none		;; return-type	
               (,<adw-toast>)	;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-lists>) initargs)
  (next-method)

  #;(set-expressions self)
  #;(bind-properties self)

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((demo-window (get-root self))
                    (toast-overlay (slot-ref demo-window 'toast-overlay)))
               (add-toast toast-overlay toast))))

  (connect (!entry-row-1 self)
           'apply
           (lambda (entry-row)
             (emit self 'add-toast
                   (make <adw-toast> #:title "Changes applied")))))


;;;
;;; set expressions
;;;


;;;
;;; bind properties
;;;


;;;
;;; notify callback
;;;


;;;
;;; utils
;;;

#;(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))
