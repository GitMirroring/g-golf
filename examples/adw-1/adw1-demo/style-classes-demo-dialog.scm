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


(define-module (adw1-demo style-classes-demo-dialog)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-style-classes-demo-dialog>))


(g-export !devel
          !status-page-dialog
          !status-page-action-row
          !sidebar-dialog
          !sidebar-action-row
          !sidebar-split-view
          !sidebar-list
          !devel-switch-row)


(eval-when (expand load eval)
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Dialog"
        "NavigationSplitView"
        "ActionRow"
        "SwitchRow")))


(define-class <adw-style-classes-demo-dialog> (<adw-dialog>)
  ;; slots
  (devel #:g-param '(boolean
                     #:default #f)
         #:accessor !devel)
  (progress-bar #:child-id "progress-bar"
                #:accessor !progress-bar)
  (status-page-dialog #:child-id "status-page-dialog"
                       #:accessor !status-page-dialog)
  (status-page-action-row #:child-id "status-page-action-row"
                           #:accessor !status-page-action-row)
  (sidebar-dialog #:child-id "sidebar-dialog"
                  #:accessor !sidebar-dialog)
  (sidebar-action-row #:child-id "sidebar-action-row"
                      #:accessor !sidebar-action-row)
  (sidebar-split-view #:child-id "sidebar-split-view"
                      #:accessor !sidebar-split-view)
  (sidebar-list #:child-id "sidebar-list"
                #:accessor !sidebar-list)
  (devel-switch-row #:child-id "devel-switch-row"
                    #:accessor !devel-switch-row)
  (progress-bar-switch-row #:child-id "progress-bar-switch-row"
                           #:accessor !progress-bar-switch-row)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/style-classes-demo-dialog.ui")
  #:child-ids '("progress-bar"
                "status-page-dialog"
                "status-page-action-row"
                "sidebar-dialog"
                "sidebar-action-row"
                "sidebar-split-view"
                "sidebar-list"
                "devel-switch-row"
                "progress-bar-switch-row"))


(define-method (initialize (self <adw-style-classes-demo-dialog>) initargs)
  (next-method)

  (bind-property (!progress-bar self)
                 "visible"
                 (!progress-bar-switch-row self)
                 "active"
                 '(sync-create bidirectional))

  (connect (!status-page-action-row self)
           'activated
           (lambda (r)
             (present (!status-page-dialog self))))

  (connect (!sidebar-action-row self)
           'activated
           (lambda (r)
             (present (!sidebar-dialog self))))

  (connect (!sidebar-list self)
           'row-activated
           (lambda (list-box row)
             (set-show-content (!sidebar-split-view self) #t)))

  (connect (!devel-switch-row self)
           'notify::active
           (lambda (switch-row p-spec)
             (notify-devel-switch-row-cb self switch-row))))

(define (notify-devel-switch-row-cb window switch-row)
  (let ((devel (!active switch-row)))
    (if devel
        (begin
          (add-css-class window "devel")
          (add-css-class (!status-page-dialog window) "devel"))
        (begin
          (remove-css-class window "devel")
          (remove-css-class (!status-page-dialog window) "devel")))
    (set! (!devel window) devel)))
