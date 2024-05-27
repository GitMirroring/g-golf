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


(define-module (adw1-demo split-views-overlay-dialog)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-split-views-overlay-dialog>))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Dialog"
        "OverlaySplitView"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("ToggleButton"
        "PackType")))


(define-class <adw-split-views-overlay-dialog> (<adw-dialog>)
  ;; slots
  (view-sidebar-start-button #:child-id "view-sidebar-start-button"
                             #:accessor !view-sidebar-start-button)
  (view-sidebar-end-button #:child-id "view-sidebar-end-button"
                           #:accessor !view-sidebar-end-button)
  (split-view #:child-id "split-view" #:accessor !split-view)
  (start-button #:child-id "start-button" #:accessor !start-button)
  (end-button #:child-id "end-button" #:accessor !end-button)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/split-views-overlay-dialog.ui")
  #:child-ids '("view-sidebar-start-button"
                "view-sidebar-end-button"
                "split-view"
                "start-button"
                "end-button"))


(define-method (initialize (self <adw-split-views-overlay-dialog>) initargs)
  (next-method)

  #;(set-expressions self)
  (bind-properties self)

  (connect (!start-button self)
           'notify::active
           (lambda (button pspec)
             (notify-start-button-active-cb self)))

  #;(notify-start-button-active-cb self))

  
;;;
;;; bind properties
;;;

(define (bind-properties split-views-page)
  (bind-property (!start-button split-views-page)
                 "active"
                 (!view-sidebar-start-button split-views-page)
                 "visible"
                 '(sync-create))

  (bind-property (!view-sidebar-start-button split-views-page)
                 "active"
                 (!view-sidebar-end-button split-views-page)
                 "active"
                 '(sync-create bidirectional))

  (bind-property (!end-button split-views-page)
                 "active"
                 (!view-sidebar-end-button split-views-page)
                 "visible"
                 '(sync-create))

  (bind-property (!view-sidebar-start-button split-views-page)
                 "active"
                 (!split-view split-views-page)
                 "show-sidebar"
                 '(sync-create bidirectional)))


;;;
;;; notify callback
;;;

(define (notify-start-button-active-cb split-views-page)
  (let ((split-view (!split-view split-views-page))
        (start-button (!start-button split-views-page)))
    (set-sidebar-position split-view
                          (if (get-active start-button) 'start 'end))))
