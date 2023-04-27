#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -e main -s "$0" "$@"
!#


;;;;
;;;; Copyright (C) 2022 - 2023
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


(eval-when (expand load eval)
  (use-modules (oop goops))

  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last))

  (use-modules (g-golf))

  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow"
        "Box"
        "Label"
        "Button")))


(define (activate app)
  (let ((window (make <gtk-application-window>
                  #:title "Hello"
                  #:default-width 320
                  #:default-height 240
                  #:application app))
        (box    (make <gtk-box>
                  #:margin-top 6
                  #:margin-start 6
                  #:margin-bottom 6
                  #:margin-end 6
                  #:orientation 'vertical))
        (label  (make <gtk-label>
                  #:label "Hello, World!"
                  #:hexpand #t
                  #:vexpand #t))
        (button (make <gtk-button>
                  #:label "Close")))

    (connect button
	     'clicked
	     (lambda (b)
               (close window)))

    (set-child window box)
    (append box label)
    (append box button)
    (present window)))


(define (main args)
  (let ((app (make <gtk-application>
               #:application-id "org.gtk.example")))
    (connect app 'activate activate)
    (let ((status (g-application-run app args)))
      (exit status))))
