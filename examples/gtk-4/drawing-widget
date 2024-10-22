#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -e main -s "$0" "$@"
!#


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


(eval-when (expand load eval)
  (use-modules (oop goops))

  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last))

  (use-modules (g-golf))

  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow")))


(define-class <drawing-widget> (<gtk-widget>))

(define-vfunc (snapshot-vfunc (self <drawing-widget>) snapshot)
  (let ((width (/ (get-width self) 2))
        (height (/ (get-height self) 2)))
    (append-color snapshot
                  ;; '(0.8 0.0 0.0 1.0)	  ;; %tango-scarlet-red
                  '(0.93 0.08 0.08 1.0)   ;; danger red
                  (graphene-rect-init (graphene-rect-alloc)
                                      0 0 width height))
    (append-color snapshot
                  ;; '(0.31 0.6 0.02 1.0) ;; %tango-chameleon-dark
                  '(0.18 0.8 0.44 1.0)	  ;; icon green
                  (graphene-rect-init (graphene-rect-alloc)
                                      width 0 width height))
    (append-color snapshot
                  ;; '(0.93 0.83 0.0 1.0) ;; %tango-butter
                  '(0.99 0.74 0.29 1.0)   ;; icon yellow
                  (graphene-rect-init (graphene-rect-alloc)
                                      0 height width height))
    (append-color snapshot
                  ;; '(0.13 0.29 0.53 1.0) ;; %tango-sky-blue-dark
                  '(0.16 0.5 0.73 1.0)     ;; abyss blue
                  (graphene-rect-init (graphene-rect-alloc)
                                      width height width height))))


(define (activate app)
  (let ((window (make <gtk-application-window>
                  #:title "Drawing Widget"
                  #:default-width 320
                  #:default-height 320
                  #:application app))
        (drawing-widget (make <drawing-widget>)))
    (set-child window drawing-widget)
    (present window)))


(define (main args)
  (letrec ((debug? (or (member "-d" args)
                       (member "--debug" args)))
           (animate
            (lambda ()
              (let ((app (make <gtk-application>
                           #:application-id "org.gnu.g-golf.drawing-widget")))
                (connect app 'activate activate)
                (let ((status (g-application-run app '())))
                  #;(exit status)
                  (dimfi 'status status))))))
    (if debug?
        (parameterize ((%debug #t))
          (animate))
        (animate))))
