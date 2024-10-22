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


(define-module (demos demo-layout-2)
  #:use-module ((rnrs base) #:select (mod))
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-2-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<demo-layout-2>))


(g-export !position
          !offset)


(define-class <demo-layout-2> (<gtk-layout-manager>)
  (position #:accessor !position #:init-value 0)	;; FIXME
  (offset #:accessor !offset #:init-value 0))		;; FIXME

#;(define-method (initialize (self <demo-layout-2>) initargs)
    (next-method))

(define-vfunc (get-request-mode-vfunc (self <demo-layout-2>) widget)
  'constant-size)

(define-vfunc (measure-vfunc (self <demo-layout-2>)
                             widget
                             orientation for-size)
  (receive (min-size nat-size)
      (min-nat-child-max-size widget orientation)
    (values min-size
            (* 3 nat-size)
            nil			;; minimum-baseline
            nil)))		;; natural-baseline

(define-vfunc (allocate-vfunc (self <demo-layout-2>)
                              widget
                              width height baseline)
  (let* ((position (!position self))
         (offset (!offset self))
         (first-child (get-first-child widget)))
     (match (get-preferred-size first-child)
       ((child-req-width child-req-height)
        (let ((w child-req-width)
              (h child-req-height)
              (r 300)
              (x0 300)
              (y0 300))
          (do ((child first-child
                      (get-next-sibling child))
               (i 0
                  (+ i 1)))
              ((not child))
            (let* ((j (float->int (/ i 36)))
                   (k (modulo i 36))
                   (t-1 (degree->radian (map-offset (+ offset (* 10 j)))))
                   (t-2 (degree->radian (map-offset (+ offset (* 10 (+ j 1))))))
                   (p-1 (degree->radian (+ position (* 10 k))))
                   (p-2 (degree->radian (+ position (* 10 (+ k 1))))))
              (set-child-visible child #f)
              (if (< t-2 t-1)
                  'skip-this-child
                  (if (or (> (sc-z r t-1 p-1) 0)
                          (> (sc-z r t-2 p-1) 0)
                          (> (sc-z r t-1 p-2) 0)
                          (> (sc-z r t-2 p-2) 0))
                      'skip-this-child
                      (begin
                        (set-child-visible child #t)
                        (receive (p1 p2 p3 p4)
                            (init-p1->p4 w h)
                          (receive (q1 q2 q3 q4)
                              (init-q1->q4 x0 y0 r t-1 t-2 p-1 p-2)
                            (let* ((matrix (perspective-3d p1 p2 p3 p4
                                                           q1 q2 q3 q4))
                                   (transform (gsk-transform-matrix #f matrix))
                                   ;; /*
                                   ;; * as matrix was built to transform points with z = 1,
                                   ;; * prepend a translation to the z = 1 plane.
                                   ;; */
                                   (transform (gsk-transform-translate-3d transform
                                                                          '(0 0 1))))
                              (allocate child
                                        w
                                        h
                                        -1
                                        transform))))))))))))))

(define (init-p1->p4 w h)
   (values (list w h 1) ;; graphene point3d init
           (list w 0 1)
           (list 0 0 1)
           (list 0 h 1)))

(define (init-q1->q4 x0 y0 r t-1 t-2 p-1 p-2)
  (values (list (+ x0 (sc-x r t-1 p-1))		;; q1
                (+ y0 (sc-y r t-1 p-1))
                (sc-z r t-1 p-1))
          (list (+ x0 (sc-x r t-2 p-1))		;; q2
                (+ y0 (sc-y r t-2 p-1))
                (sc-z r t-2 p-1))
          (list (+ x0 (sc-x r t-2 p-2))		;; q3
                (+ y0 (sc-y r t-2 p-2))
                (sc-z r t-2 p-2))
          (list (+ x0 (sc-x r t-1 p-2))		;; q4
                (+ y0 (sc-y r t-1 p-2))
                (sc-z r t-1 p-2))))


;;;
;;; utils
;;;

(define (min-nat-child-max-size widget orientation)
  (let loop ((child (get-first-child widget))
             (minimum-size 0)
             (natural-size 0))
    (match child
      (#f
       (values minimum-size
               natural-size))
      (else
       (if (should-layout child)
           (receive (child-min child-nat foo bar)
               (measure child orientation -1)
             (loop (get-next-sibling child)
                   (max minimum-size child-min)
                   (max natural-size child-nat)))
           (loop (get-next-sibling child)
                 minimum-size
                 natural-size))))))

(define %pi (acos -1))
(define %2pi (* %pi 2))
(define %pi/2 (/ %pi 2))

(define (radian->degree rad)
  (/ (* rad 180) %pi))

(define (degree->radian deg)
  (/ (* deg %pi) 180))

(define (sc-x r t p)
  (* r (sin t) (cos p)))

(define (sc-z r t p)
  (* r (sin t) (sin p)))

(define (sc-y r t p)
  (* r (cos t)))

(define (map-offset x)
  (let ((x (mod x 180.0)))
    (if (< x 0.0)
        (+ x 180.0)
        x)))

(define (perspective-3d p1 p2 p3 p4 q1 q2 q3 q4)
  (let ((matrix (graphene-matrix-alloc)))
    (apply perspective_3d
           (append (map (lambda (point3d)
                          (make-c-struct (list float float float) point3d))
                     (list p1 p2 p3 p4 q1 q2 q3 q4))
                   (list matrix)))
    matrix))


;;;
;;; graphene utils
;;;

