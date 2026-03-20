;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023 - 2026
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


(define-module (demos nuclear-icon)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (cairo)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<nuclear-icon>
            nuclear-snapshot-cairo
            nuclear-snapshot-gsk
            %cairo?))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Paintable"))

  (for-each (lambda (name)
              (gi-import-by-name "Gsk" name))
      '("PathBuilder"
        "Stroke"))

  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Snapshot")))


(define %cairo? (make-parameter #f))


(define-class <nuclear-icon> (<gobject> <gdk-paintable>)
  (rotation #:accessor !rotation #:init-keyword #:rotation))

(define-vfunc (get-flags-vfunc (self <nuclear-icon>))
  '(static-size static-contents))

(define-vfunc (snapshot-vfunc (self <nuclear-icon>) snapshot width height)
  (if (%cairo?)
      (nuclear-snapshot-cairo snapshot
                              '(0.9 0.75 0.15 1.0)	;; nuclear yellow
                              '(0.0 0.0 0.0 1.0)	;; black
                              width
                              height
                              (!rotation self))
      (nuclear-snapshot-gsk snapshot
                            '(0.9 0.75 0.15 1.0)	;; nuclear yellow
                            '(0.0 0.0 0.0 1.0)		;; black
                            width
                            height
                            (!rotation self))))

(define (nuclear-snapshot-cairo snapshot background foreground width height rotation)
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

(define (nuclear-snapshot-gsk snapshot background foreground width height rotation)
  (append-color snapshot
                background
                (graphene-rect-init (graphene-rect-alloc) 0 0 width height))
  (let* ((radius 0.3)
         (pi (acos -1))
         (size (min width height))
         (builder (gsk-path-builder-new))
         (stroke (gsk-stroke-new radius)))
    (save snapshot)

    (let ((point (graphene-point-alloc)))
      (translate snapshot
                 (graphene-point-init point (/ width 2) (/ height 2))))
    (scale snapshot size size)
    (rotate snapshot rotation)

    (gsk-path-builder-add-circle builder (graphene-point-zero) 0.1)
    (let ((path (gsk-path-builder-to-path builder)))
      (append-fill snapshot path 'winding foreground)
      (gsk-path-unref path))

    (gsk-stroke-set-dash stroke (list (/ (* radius pi) 3)))
    (let ((builder (gsk-path-builder-new)))
      (gsk-path-builder-add-circle builder (graphene-point-zero) radius)
      (let ((path (gsk-path-builder-to-path builder)))
        (append-stroke snapshot path stroke foreground)
        (gsk-path-unref path)
        (gsk-stroke-free stroke)))

    (restore snapshot)))
