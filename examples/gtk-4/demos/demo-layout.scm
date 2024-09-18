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


(define-module (demos demo-layout)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-init)
  #:use-module (demos demo-child)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<demo-layout>))


(g-export !position
          !pos
          shuffle)


(define-class <demo-layout> (<gtk-layout-manager>)
  (position #:accessor !position #:init-value 0.0)
  (pos #:accessor !pos))

(define-method (initialize (self <demo-layout>) initargs)
  (next-method)
  (set! (!pos self)
        (demo-layout-pos-vector)))

(define-vfunc (get-request-mode-vfunc (self <demo-layout>) widget)
  'constant-size)

(define-vfunc (measure-vfunc (self <demo-layout>)
                             widget
                             orientation for-size)
  (receive (min-size nat-size)
      (min-nat-child-max-size widget orientation)
    ;; /*
    ;; * A back-of-a-napkin calculation to reserve enough
    ;; * space for arranging 16 children in a circle.
    ;; */
    (values (float->int (+ (/ (* 16 min-size) %pi) min-size))	;; minimum
            (float->int (+ (/ (* 16 nat-size) %pi) nat-size))	;; natural
            nil							;; minimum-baseline
            nil)))						;; natural-baseline

(define-vfunc (allocate-vfunc (self <demo-layout>)
                              widget
                              width height baseline)
  (let* ((t (!position self))
         (x0 (float->int (/ width 2)))
         (y0 (float->int (/ height 2))))
    (receive (child-width child-height)
        (pref-width-height-child-max-size widget)
      (let ((r (/ (* child-width 8) %pi)))
        (do ((child (get-first-child widget)
                    (get-next-sibling child))
             (i 0
                (+ i 1)))
            ((not child))
          (when (should-layout child)
            (let ((a (/ (* (vector-ref (!pos self) i) %pi) 8)))
              (match (get-preferred-size child)
                ((pref-width pref-height)
                 (let* ( ;; the grid position of child.
                        (gx (+ x0 (* (- (modulo i 4) 2) child-width)))
                        (gy (+ y0 (* (- (quotient i 4) 2) child-height)))
                        ;; the circle position of child.
                        ;; Note that we are adjusting the position by half
                        ;; the child size to place the center of child on a
                        ;; centered circle. This assumes that the children
                        ;; don't use align flags or uneven margins that
                        ;; would shift the center.
                        (cx (- (+ (* (sin a) r) x0) (/ pref-width 2)))
                        (cy (- (+ (* (cos a) r) y0) (/ pref-height 2)))
                        (x (float->int (+ (* cx t) (* (- 1 t) gx))))
                        (y (float->int (+ (* cy t) (* (- 1 t) gy)))))
                   (size-allocate child
                                  (list x y child-width child-height)
                                  -1)))))))))))

(define-method (shuffle (self <demo-layout>))
  (let ((pos (!pos self)))
    (for-each (lambda (i)
                (let ((j (random (+ i 1)))
                      (tmp (vector-ref pos i)))
                  (vector-set! pos i (vector-ref pos j))
                  (vector-set! pos j tmp)))
        (iota 16))))


;;;
;;; utils
;;;

(define %pi (acos -1))
                    
(define (demo-layout-pos-vector)
  (let ((pos (make-vector 16)))
    (for-each (lambda (i)
                (vector-set! pos i i))
        (iota 16))
    pos))

(define (min-nat-child-max-size widget orientation)
  (let loop ((child (get-first-child widget))
             (minimum-size 0)
             (natural-size 0))
    (match child
      (#f
       (values minimum-size
               natural-size))
      (else
       (receive (child-min child-nat foo bar)
           (measure child orientation -1)
         (loop (get-next-sibling child)
               (max minimum-size child-min)
               (max natural-size child-nat)))))))

(define (pref-width-height-child-max-size widget)
  (let loop ((child (get-first-child widget))
             (child-width 0)
             (child-height 0))
    (match child
      (#f
       (values child-width
               child-height))
      (else
       (match (get-preferred-size child)
         ((child-req-width child-req-height)
          (loop (get-next-sibling child)
                (max child-width child-req-width)
                (max child-height child-req-height))))))))
