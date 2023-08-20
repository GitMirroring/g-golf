;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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


(define-module (adw1-demo leaflet)
  #:use-module (oop goops)
  #:use-module (g-golf)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-leaflet>
            %adw-leaflet-transition-type))


(g-export !transition-type
          !transition-row
          !action-row)


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("ClosureExpression"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Bin"
        "Clamp"
        "PreferencesGroup"
        "StatusPage"
        "ComboRow"
        "ActionRow"
        "EnumListModel"
        "EnumListItem"
        "LeafletTransitionType")))


(define %adw-leaflet-transition-type #f)

(eval-when (expand load eval)
  (set! %adw-leaflet-transition-type
        (gi-cache-ref 'enum 'adw-leaflet-transition-type)))


(define-class <adw-demo-page-leaflet> (<adw-bin>)
  ;; slots
  (transition-type #:g-param `(enum
                               #:type ,%adw-leaflet-transition-type)
                   #:accessor !transition-type)
  (transition-row #:child-id "transition-row" #:accessor !transition-row)
  (action-row #:child-id "action-row" #:accessor !action-row)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/leaflet.ui")
  #:child-ids '("transition-row"
                "action-row")
  #:g-signal '(next-page	;; name
               none		;; return-type	
               ()		;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-leaflet>) initargs)
  (next-method)
  ;; AdwComboRow requires their expression property to be set, it is
  ;; used to bind strings to the labels produced by the default factory
  ;; (if AdwComboRow:factory is not set).
  (let ((transition-row (!transition-row self))
        (action-row (!action-row self))
        (closure (transition-name-closure)))

    (set! (!expression transition-row)
          (make-expression 'string closure '()))

    (bind-property transition-row
                   "selected"
                   self
                   "transition-type"
                   '(sync-create bidirectional))

    (connect action-row
             "activated"
             (lambda (r)
               (emit self 'next-page)))))

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))

(define (get-transition-name adw-enum-list-item)
  (case (!value adw-enum-list-item)
    ((0) "Over")	;; later (G_ "Over")
    ((1) "Under")	;; ...
    ((2) "Slide")
    (else
     (scm-error 'unlikely #f "This instance is a ghost: ~S"
                (list adw-enum-list-item) #f))))

(define (transition-name-closure)
  (make <closure>
    #:function get-transition-name
    #:return-type 'string
    #:param-types (list <adw-enum-list-item>)))
