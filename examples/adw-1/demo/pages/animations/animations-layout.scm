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


(define-module (pages animations animations-layout)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<animation-layout>))


#;(g-export )


(define-class <animation-layout> (<gtk-layout-manager>))

;; no thing special here, so no need to specialize
#;(define-method (initialize (self <animation-layout>) initargs)
  (next-method))

(define-vfunc (measure-vfunc (self <animation-layout>)
                             scene			;; widget
                             orientation for-size)
  (let ((child (get-first-child scene)))
    (receive (minimum natural minimum-baseline natural-baseline)
        (measure child orientation for-size)
      (values minimum
              natural
              minimum-baseline
              natural-baseline))))

(define-vfunc (allocate-vfunc (self <animation-layout>)
                              scene			;; widget
                              width height baseline)
  (let ((child (get-first-child scene))
        (progress (get-progress scene)))
    (receive (child-width natural minimum-baseline natural-baseline)
        (measure child 'horizontal -1)
      (allocate child width height baseline
                (transform width child-width progress)))))


;;;
;;; utils
;;;

(define get-progress #f)

(let ((%animations-page #f))
  (set! get-progress
        (lambda (scene)
          (let* ((ancestor
                  (or %animations-page
                      (let ((ancestor (get-animations-page scene)))
                        (set! %animations-page ancestor)
                        ancestor)))
                 (animation (slot-ref ancestor 'current-animation)))
            (get-value animation)))))

(define (get-animations-page scene)
  (let* ((module (resolve-module '(pages animations animations)))
         (ancestor-class (module-ref module '<adw-demo-page-animations>))
         (ancestor-g-type (!g-type ancestor-class)))
    (get-ancestor scene ancestor-g-type)))

(define (get-offset width child-width progress)
  (* (- width child-width) (- progress 0.5)))

(define (transform width child-width progress)
  (let* ((offset (get-offset width child-width progress))
         (point (graphene-point-init (graphene-point-alloc) offset 0))
         (transform-translate (gsk-transform-translate #f point)))
    (graphene-point-free point)
    transform-translate))
