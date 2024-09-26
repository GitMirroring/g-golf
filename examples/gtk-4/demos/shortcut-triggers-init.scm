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


(define-module (demos shortcut-triggers-init)
  #:use-module (oop goops)
  #:use-module (g-golf)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last))


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  #;(for-each (lambda (name)
              (gi-import-by-name "Gio" name))
      '("SimpleActionGroup"
        "SimpleAction"
        "ActionMap"))
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("ModifierType"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow"
        "ListBox"
        "Label"
        "ShortcutController"
        "ShortcutScope"
        "Shortcut"
        "KeyvalTrigger"
        ;; "NamedAction"
        "CallbackAction")))
