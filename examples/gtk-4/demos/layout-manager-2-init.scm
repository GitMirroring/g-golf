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


(define-module (demos layout-manager-2-init)
  #:use-module (oop goops)
  #:use-module (g-golf)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:declarative? #f

  #:export (%libfpt
            perspective_3d))


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gio" name))
      '("SimpleActionGroup"
        "SimpleAction"
        "ActionMap"))
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Rectangle"
        "FrameClock"
        "ModifierType"))
  (for-each (lambda (name)
              (gi-import-by-name "Gsk" name))
      '("Transform"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow"
        "Snapshot"
        "Orientation"
        "GestureClick"
        "LayoutManager"
        "SizeRequestMode"
        "Requisition"
        "Shortcut"
        "ShortcutController"
        "ShortcutScope"
        "KeyvalTrigger"
        "NamedAction"
        "Image")))

(define %libfpt #f)
(define perspective_3d #f)

(eval-when (expand load eval)
  (let* ((path (dirname (current-filename)))
         (libfpt (string-append path "/libfpt.so")))
    (set! %libfpt
          (if (access? libfpt R_OK)
              (dynamic-link libfpt)
              (begin
                (system (string-append "cd " path "; make"))
                (dynamic-link libfpt))))
    (set! perspective_3d
          (pointer->procedure void
                              (dynamic-func "perspective_3d"
                                            %libfpt)
                              (list '*		;; *p1
                                    '*		;; *p2
                                    '*		;; *p3
                                    '*		;; *p4
                                    '*		;; *q1
                                    '*		;; *q2
                                    '*		;; *q3
                                    '*		;; *q4
                                    '*)))))	;; *m
