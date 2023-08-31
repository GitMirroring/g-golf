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


(define-module (adw1-demo preferences)
  #:use-module (oop goops)
  #:use-module (g-golf)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-preferences-window>))


(g-export !toast-bt
          !go-to-subpage-1-ar
          !subpage-1
          !subpage-1-bt
          !go-to-subpage-2-ar
          !subpage-2
          !subpage-2-bt)


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Button"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("StatusPage"
        "PreferencesWindow"
        "PreferencesPage"
        "PreferencesGroup"
        "Toast"
        "ComboRow"
        "ActionRow")))


(define-class <adw-demo-preferences-window> (<adw-preferences-window>)
  ;; slots
  (toast-bt #:child-id "toast-bt" #:accessor !toast-bt)
  (go-to-subpage-1-ar #:child-id "go-to-subpage-1-ar"
                      #:accessor !go-to-subpage-1-ar)
  (subpage-1 #:child-id "subpage-1" #:accessor !subpage-1)
  (subpage-1-bt #:child-id "subpage-1-bt" #:accessor !subpage-1-bt)
  (go-to-subpage-2-ar #:child-id "go-to-subpage-2-ar"
                      #:accessor !go-to-subpage-2-ar)
  (subpage-2 #:child-id "subpage-2" #:accessor !subpage-2)
  (subpage-2-bt #:child-id "subpage-2-bt" #:accessor !subpage-2-bt)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/preferences.ui")

  #:child-ids '("toast-bt"
                "go-to-subpage-1-ar"
                "subpage-1"
                "subpage-1-bt"
                "go-to-subpage-2-ar"
                "subpage-2"
                "subpage-2-bt"))


(define-method (initialize (self <adw-demo-preferences-window>) initargs)
  (next-method)

  (connect (!toast-bt self)
           'clicked
           (lambda (b)
             (toast-show-cb self)))

  (connect (!go-to-subpage-1-ar self)
           'activated
           (lambda (r)
             (go-to-subpage-1-ar-cb self)))

  (connect (!subpage-1-bt self)
           'clicked
           (lambda (b)
             (return-to-preferences-cb self)))

  (connect (!go-to-subpage-2-ar self)
           'activated
           (lambda (r)
             (go-to-subpage-2-ar-cb self)))

  (connect (!subpage-2-bt self)
           'clicked
           (lambda (b)
             (return-to-preferences-cb self))))

(define (toast-show-cb prefs-win)
  (add-toast prefs-win (make <adw-toast> #:title "Example Toast")))

(define (go-to-subpage-1-ar-cb prefs-win)
  (present-subpage prefs-win (!subpage-1 prefs-win)))

(define (go-to-subpage-2-ar-cb prefs-win)
  (present-subpage prefs-win (!subpage-2 prefs-win)))

(define (return-to-preferences-cb prefs-win)
  (close-subpage prefs-win))
