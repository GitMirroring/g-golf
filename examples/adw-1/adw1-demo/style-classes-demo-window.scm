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


(define-module (adw1-demo style-classes-demo-window)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-style-classes-demo-window>))


(g-export !devel
          !progress-bar
          !status-pages-window
          !status-pages-action-row
          !sidebar-window
          !sidebar-action-row
          !sidebar-split-view
          !sidebar-list
          !devel-switch-row)


(eval-when (expand load eval)
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Window"
        "NavigationSplitView"
        "ActionRow"
        "SwitchRow")))


(define-class <adw-style-classes-demo-window> (<adw-window>)
  ;; slots
  (devel #:g-param '(boolean
                     #:default #f)
         #:accessor !devel)
  #;(progress-bar #:g-param '(boolean
                            #:default #f)
                #:accessor !progress-bar)
  (progress-bar #:child-id "progress-bar"
                #:accessor !progress-bar)
  (status-pages-window #:child-id "status-pages-window"
                       #:accessor !status-pages-window)
  (status-pages-action-row #:child-id "status-pages-action-row"
                           #:accessor !status-pages-action-row)
  (sidebar-window #:child-id "sidebar-window"
                  #:accessor !sidebar-window)
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
                            "/ui/style-classes-demo-window.ui")
  #:child-ids '("progress-bar"
                "status-pages-window"
                "status-pages-action-row"
                "sidebar-window"
                "sidebar-action-row"
                "sidebar-split-view"
                "sidebar-list"
                "devel-switch-row"
                "progress-bar-switch-row"))


(define-method (initialize (self <adw-style-classes-demo-window>) initargs)
  (next-method)

  (bind-property (!progress-bar self)
                 "visible"
                 (!progress-bar-switch-row self)
                 "active"
                 '(sync-create bidirectional))

  (connect (!status-pages-action-row self)
           'activated
           (lambda (r)
             (present (!status-pages-window self))))

  (connect (!sidebar-action-row self)
           'activated
           (lambda (r)
             (present (!sidebar-window self))))

  (connect (!sidebar-list self)
           'row-activated
           (lambda (list-box row)
             (set-show-content (!sidebar-split-view self) #t)))

  (connect (!devel-switch-row self)
           'notify::active
           (lambda (switch-row val)
             ;; FIXME
             ;; - the second arg
             ;;     g-closure-marshal-g-value-ref <- must be enhanced
             #;(dimfi switch-row val (g-object-type-name val))
             (notify-devel-switch-row-cb self))))

(define (notify-devel-switch-row-cb window)
  (let ((devel (not (!devel window))))
    (if devel
        (begin
          (add-css-class window "devel")
          (add-css-class (!status-pages-window window) "devel"))
        (begin
          (remove-css-class window "devel")
          (remove-css-class (!status-pages-window window) "devel")))
    (set! (!devel window) devel)))
