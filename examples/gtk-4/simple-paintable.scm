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

;; Note: this example requires guile-cairo, a patched verison of
;; guile-cairo:

;;	https://www.nongnu.org/guile-cairo/

;; It actually needs a patched version of guile-cairo, that contains the
;; following new interface (which is not in guile-cairo 1.11.2):

;;	cairo-pointer->context

;; If by the time you have access to and wish to try this example
;; guile-cairo hasn't been released and/or cairo-pointer->context still
;; isn't commited to the latest guile-cairo repository master branch,
;; get in touch with us on irc.libera.chat, channel #guile, or by email,
;; we'll guide you to manually patch your local version.

;;; Code:


(eval-when (expand load eval)
  (use-modules (oop goops))

  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last))

  (use-modules (g-golf)
               (cairo))

  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Paintable"))

  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow"
        "Image")))


(define-class <nuclear-icon> (<gobject> <gdk-paintable>)
  (rotation #:accessor !rotation #:init-keyword #:rotation))

(define-vfunc (get-flags-vfunc (self <nuclear-icon>))
  '(size contents))

(define-vfunc (snapshot-vfunc (self <nuclear-icon>) snapshot width height)
  (nuclear-snapshot snapshot
                    '(0.9 0.75 0.15 1.0)	;; nuclear yellow
                    '(0.0 0.0 0.0 1.0)		;; black
                    width
                    height
                    (!rotation self)))

(define (nuclear-snapshot snapshot background foreground width height rotation)
  (append-color snapshot
                background
                (graphene-rect-init (graphene-rect-alloc) 0 0 width height))
  (let* ((size (min width height))
         (ctx (append-cairo snapshot
                            (graphene-rect-init (graphene-rect-alloc)
                                                (/ (- width size) 2)
                                                (/ (- height size) 2)
                                                size
                                                size)))
         (cr (cairo-pointer->context ctx))
         (radius 0.3)
         (pi (acos -1)))
    (match foreground
      ((r g b a)
       (cairo-set-source-rgba cr r g b a)))
    (cairo-translate cr (/ width 2.0) (/ height 2.0))
    (cairo-scale cr size size)
    (cairo-rotate cr rotation)

    (cairo-arc cr 0 0 0.1 (- pi) pi)
    (cairo-fill cr)

    (cairo-set-line-width cr radius)
    (cairo-set-dash cr `#(,(/ (* radius pi) 3)) 0.0)
    (cairo-arc cr 0 0 radius (- pi) pi)
    (cairo-stroke cr)
    (cairo-destroy cr)))


(define (activate app)
  (let ((window (make <gtk-application-window>
                  #:title "Nuclear Icon"
                  #:default-width 300
                  #:default-height 200
                  #:application app))
        (nuclear (make <nuclear-icon> #:rotation 0.0))
        (image (make <gtk-image>)))
    (set-from-paintable image nuclear)
    (set-child window image)
    (show window)))


(define (main args)
  (let ((app (make <gtk-application>
               #:application-id "org.gtk.example")))
    (connect app 'activate activate)
    (let ((status (g-application-run app args)))
      (exit status))))
