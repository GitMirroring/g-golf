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

;; In this g-golf port of the upstream example, so as to avoid the use
;; of g-variant, we define four actions, one for each sphere rotate
;; direction.

;;; Code:


(define-module (demos demo-widget-2)
  #:use-module (srfi srfi-19)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-init)
  #:use-module (demos demo-layout-2)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<demo-widget-2>))


(g-export add-child)


(define-class <demo-widget-2> (<gtk-widget>)
  (start-time #:accessor !start-time #:init-keyword #:start-time)
  (end-time #:accessor !end-time #:init-keyword #:end-time)
  (start-position #:accessor !start-position #:init-keyword #:start-position)
  (end-position #:accessor !end-position #:init-keyword #:end-position)
  (start-offset #:accessor !start-offset #:init-keyword #:start-offset)
  (end-offset #:accessor !end-offset #:init-keyword #:end-offset)
  (animating #:accessor !animating #:init-keyword #:animating #:init-value #f)
  ;; class options
  #:layout-manager <demo-layout-2>)

(define-method (initialize (self <demo-widget-2>) initargs)
  (next-method)
  (set-focusable self #t)
  (install-actions self)
  (install-shortcuts self))

(define-method (add-child (self <demo-widget-2>) child)
  (set-parent child self))

(define-vfunc (dispose-vfunc (self <demo-widget-2>))
  (let loop ((child (get-first-child self)))
    (match child
      (#f (values))
      (else
       (unparent child)
       (loop (get-first-child self)))))
  (next-vfunc))

(define-vfunc (snapshot-vfunc (self <demo-widget-2>) snapshot)
  (let loop ((child (get-first-child self)))
    (match child
      (#f (values))
      (else
       ;; the layout-manager sets the- child visibility to #f for children
       ;; that are out of the view.
       (when (get-child-visible child)
         (snapshot-child self child snapshot))
       (loop (get-next-sibling child))))))


;;;
;;; install actions
;;;

(define (install-actions demo-widget-2)
  (let ((action-map (make <g-simple-action-group>))
        (a-rotate-left (make <g-simple-action> #:name "rotate-left"))
        (a-rotate-right (make <g-simple-action> #:name "rotate-right"))
        (a-rotate-up (make <g-simple-action> #:name "rotate-up"))
        (a-rotate-down (make <g-simple-action> #:name "rotate-down")))

    (add-action action-map a-rotate-left)
    (connect a-rotate-left
             'activate
             (lambda (s-action g-variant)
               (sphere/rotate demo-widget-2 'left)))

    (add-action action-map a-rotate-right)
    (connect a-rotate-right
             'activate
             (lambda (s-action g-variant)
               (sphere/rotate demo-widget-2 'right)))

    (add-action action-map a-rotate-up)
    (connect a-rotate-up
             'activate
             (lambda (s-action g-variant)
               (sphere/rotate demo-widget-2 'up)))

    (add-action action-map a-rotate-down)
    (connect a-rotate-down
             'activate
             (lambda (s-action g-variant)
               (sphere/rotate demo-widget-2 'down)))

    (insert-action-group demo-widget-2
                         "sphere"
                         action-map)))


;;;
;;; install shortcuts
;;;

(define (install-shortcuts demo-widget-2)
  (let ((controller (make <gtk-shortcut-controller>
                      #:name "demo-widget-2-shortcuts")))
    (set-scope controller 'local)
    (add-controller demo-widget-2 controller)
    (for-each (match-lambda
                ((key-name modifiers action-name)
                 (let ((key-value
                        (gi-import-by-name "Gdk" key-name #:allow-constant? #t)))
                   (add-shortcut controller
                                 (make <gtk-shortcut>
                                   #:trigger (make <gtk-keyval-trigger>
                                               #:keyval key-value
                                               #:modifiers modifiers)
                                   #:action (make <gtk-named-action>
                                              #:action-name action-name))))))
        '(("KEY_Left" (no-modifier-mask) "sphere.rotate-left")
          ("KEY_Right" (no-modifier-mask) "sphere.rotate-right")
          ("KEY_Up" (no-modifier-mask) "sphere.rotate-up")
          ("KEY_Down" (no-modifier-mask) "sphere.rotate-down")))))


;;;
;;; callback
;;;

(define (sphere/rotate demo-widget-2 direction)
  (let* ((layout-manager (get-layout-manager demo-widget-2))
         (position (!position layout-manager))
         (offset (!offset layout-manager))
         (delta (case direction
                  ((right up) 1)
                  ((left down) -1)))
         (start-time (g-get-monotonic-time)))
    (mslot-set! demo-widget-2
                'start-position position
                'end-position position
                'start-offset offset
                'end-offset offset)
    (case direction
      ((left right)
       (set! (!end-position demo-widget-2)
             (+ (!end-position demo-widget-2) (* 10 delta))))
      ((up down)
       (set! (!end-offset demo-widget-2)
             (+ (!end-offset demo-widget-2) (* 10 delta)))))
    (mslot-set! demo-widget-2
                'start-time start-time
                'end-time (+ start-time %duration))
    (unless (!animating demo-widget-2)
      (add-tick-callback demo-widget-2 update-position #f #f)
      (set! (!animating demo-widget-2) #t))))

(define (update-position widget frame-clock user-data)
  (let* ((demo-layout (get-layout-manager widget))
         (now (get-frame-time frame-clock))
         (end-time (!end-time widget)))
    (if (>= now end-time)
        (begin
          (set! (!animating widget) #f)
          #f)
        (let* ((start-time (!start-time widget))
               (start-position (!start-position widget))
               (end-position (!end-position widget))
               (start-offset (!start-offset widget))
               (end-offset (!end-offset widget))
               (t (ease-out-cubic
                   (/ (- now start-time) (- end-time start-time)))))
          (set! (!position demo-layout)
                (+ start-position
                   (* t (- end-position start-position))))
          (set! (!offset demo-layout)
                (+ start-offset
                   (* t (- end-offset start-offset))))
          (queue-allocate widget)
          #t))))


;;;
;;; utils
;;;

(define %duration
  (* 0.5 1000000)) ;; 0.5 * G_TIME_SPAN_SECOND

(define (ease-out-cubic t)
  ;; /* From clutter-easing.c, based on Robert Penner's
  ;;  * infamous easing equations, MIT license.
  ;;  */
  (let ((p (- t 1)))
    (+ (* p p p) 1)))
