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


(define-module (demos layout-manager)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-init)
  #:use-module (demos demo-widget)
  #:use-module (demos demo-child)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (activate-demo))


#;(g-export )

(define (activate-demo app)
  (let ((window (make <gtk-application-window>
                  #:title "Layout Manager — Transition"
                  #:default-width 360
                  #:default-height 320
                  #:application app))
        (demo-widget (make <demo-widget>)))
    (populate-demo-widget demo-widget)
    (set-child window demo-widget)
    (present window)))

(define (populate-demo-widget demo-widget)
  (for-each (lambda (i)
              (let* ((color (list-ref %colors i))
                     (demo-child (make <demo-child>
                                   #:color (string->color color)
                                   #:tooltip-text color
                                   #:margin-start 4
                                   #:margin-end 4
                                   #:margin-top 4
                                   #:margin-bottom 4)))
                (add-child demo-widget demo-child)))
      (iota 16)))


;;;
;;; colors
;;;

(define %colors
  (list "red" "orange" "yellow" "green"
        "blue" "gray" "magenta" "lime"
        "yellow" "firebrick" "aqua" "purple"
        "tomato" "pink" "thistle" "maroon"))
