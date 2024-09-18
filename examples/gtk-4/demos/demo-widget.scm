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

;; /*
;;  * The widget is controlling the transition by calling
;;  * demo_layout_set_position() in a tick callback.
;;  *
;;  * We take half a second to go from one layout to the other.
;;  */

;;; Code:


(define-module (demos demo-widget)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-init)
  #:use-module (demos demo-layout)
  #:use-module (demos demo-child)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<demo-widget>))


(g-export add-child)


(define-class <demo-widget> (<gtk-widget>)
  (backward #:accessor !backward #:init-keyword #:backward #:init-value #f)
  (start-time #:accessor !start-time #:init-keyword #:start-time)
  (tick-id #:accessor !tick-id #:init-keyword #:tick-id #:init-value 0)
  ;; class options
  #:layout-manager <demo-layout>)

(define-method (initialize (self <demo-widget>) initargs)
  (next-method)
  (let ((gesture (make <gtk-gesture-click>)))
    (connect gesture
             'pressed
             (lambda (g n-press x y)
               (clicked-cb self)))
    (add-controller self gesture)))

(define-method (add-child (self <demo-widget>) child)
  (set-parent child self))


;;;
;;; callback
;;;

(define (transition widget frame-clock user-data)
  (let* ((demo-layout (get-layout-manager widget))
         (now (get-frame-time frame-clock))
         (backward (!backward widget))
         (not-backward (not backward))
         (start-time (!start-time widget))
         (position-next (/ (- now start-time) %duration)))
    (queue-allocate widget)
    (if backward
        (set! (!position demo-layout) (- 1 position-next))
        (set! (!position demo-layout) position-next))
    (if (>= (- now start-time) %duration)
        (begin
          (set! (!backward widget) not-backward)
          (set! (!position demo-layout) (if not-backward 1.0 0.0))
          (when backward (shuffle demo-layout))
          (set! (!tick-id widget) 0)
          #f)
        #t)))

(define (clicked-cb demo-widget)
  (when (= (!tick-id demo-widget) 0)
    (let ((frame-clock (get-frame-clock demo-widget)))
      (mslot-set! demo-widget
                  'start-time
                  (get-frame-time frame-clock)
                  'tick-id
                  (add-tick-callback demo-widget transition #f #f)))))


;;;
;;; utils
;;;

(define %duration
  (* 0.5 1000000)) ;; 0.5 * G_TIME_SPAN_SECOND
