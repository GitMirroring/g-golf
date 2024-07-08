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


(define-module (pages carousel carousel)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)  

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-carousel>))


#;(g-export )


(define-class <adw-demo-page-carousel> (<adw-bin>)
  ;; slot(s)
  ;; child-id slot(s)
  (carousel #:child-id "carousel" #:accessor !carousel)
  (box #:child-id "box" #:accessor !box)
  (return-bt #:child-id "return-bt" #:accessor !return-bt)
  (orientation-row #:child-id "orientation-row" #:accessor !orientation-row)
  (indicators-row #:child-id "indicators-row" #:accessor !indicators-row)
  (indicators-stack #:child-id "indicators-stack" #:accessor !indicators-stack)
  (indicators-dots #:child-id "indicators-dots" #:accessor !indicators-dots)
  (indicators-lines #:child-id "indicators-lines" #:accessor !indicators-lines)
  (scroll-wheel #:child-id "scroll-wheel" #:accessor !scroll-wheel)
  (long-swipes #:child-id "long-swipes" #:accessor !long-swipes)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/carousel/carousel-ui.ui")
  #:child-ids '("carousel"
                "box"
                "return-bt"
                "orientation-row"
                "indicators-row"
                "indicators-stack"
                "indicators-dots"
                "indicators-lines"
                "scroll-wheel"
                "long-swipes"))

(define-method (initialize (self <adw-demo-page-carousel>) initargs)
  (next-method)

  (set-expressions self)
  (bind-properties self)

  (connect (!orientation-row self)
           'notify::selected
           (lambda (combo-row pspec)
             (notify-orientation-cb self)))

  (connect (!indicators-row self)
           'notify::selected
           (lambda (combo-row pspec)
             (notify-indicators-cb self)))

  (connect (!return-bt self)
           'clicked
           (lambda (b)
             (let ((carousel (!carousel self)))
               (scroll-to carousel
                          (get-nth-page carousel 0)
                          #t)))))

;;;
;;; set expressions
;;;

(define (set-expressions carousel-page)
  ;; AdwComboRow requires their expression property to be set. It is
  ;; used to bind strings to the labels produced by the default factory
  ;; (if AdwComboRow:factory is not set).
  (let ((orientation-row (!orientation-row carousel-page))
        (indicators-row (!indicators-row carousel-page)))
    (set! (!expression orientation-row)
          (orientation-name-expression))
    (set! (!expression indicators-row)
          (indicators-name-expression))))

(define (orientation-name-expression)
  (make-expression 'string
                   (orientation-name-closure)
                   '()))

(define (orientation-name-closure)
  (make <closure>
    #:function orientation-name
    #:return-type 'string
    #:param-types `(,<adw-enum-list-item>)))

(define (orientation-name adw-enum-list-item)
  (let ((gtk-orientation (gi-cache-ref 'enum 'gtk-orientation))
        (value (!value adw-enum-list-item)))
    (case (enum->symbol gtk-orientation value)
      ((horizontal) "Horizontal") ;; (G_ "Horizontal")
      ((vertical) "Vertical")
      (else
       (displayln "Warning: unprocessed gtk orientation name.")
       (enum->name gtk-orientation value)))))

(define (indicators-name-expression)
  (make-expression 'string
                   (indicators-name-closure)
                   '()))

(define (indicators-name-closure)
  (make <closure>
    #:function indicators-name
    #:return-type 'string
    #:param-types `(,<gtk-string-object>)))

(define (indicators-name gtk-string-object)
  (let ((value (get-string gtk-string-object)))
    (case (string->symbol value)
      ((dots) "Dots") ;; (G_ "Dots")
      ((lines) "Lines")
      (else
       (displayln "Warning: unprocessed gtk indicators name.")
       value))))


;;;
;;; bind properties
;;;

(define (bind-properties carousel-page)
  (bind-property (!scroll-wheel carousel-page)
                 "active"
                 (!carousel carousel-page)
                 "allow-scroll-wheel"
                 '(sync-create bidirectional))
  (bind-property (!long-swipes carousel-page)
                 "active"
                 (!carousel carousel-page)
                 "allow-long-swipes"
                 '(sync-create bidirectional))
  (bind-property (!indicators-dots carousel-page)
                 "orientation"
                 (!carousel carousel-page)
                 "orientation"
                 '(sync-create bidirectional))
  (bind-property (!indicators-lines carousel-page)
                 "orientation"
                 (!carousel carousel-page)
                 "orientation"
                 '(sync-create bidirectional)))


;;;
;;; notify callback
;;;

(define (notify-orientation-cb carousel-page)
  (let* ((gtk-orientation (gi-cache-ref 'enum 'gtk-orientation))
         (carousel (!carousel carousel-page))
         (box (!box carousel-page))
         (orien- (get-selected (!orientation-row carousel-page)))
         (-tation (enum->symbol gtk-orientation orien-)))
    (case -tation
      ((horizontal)
       (set-orientation box 'vertical)
       (set-orientation carousel 'horizontal))
      ((vertical)
       (set-orientation box 'horizontal)
       (set-orientation carousel 'vertical)))))

(define (notify-indicators-cb carousel-page)
  (let* ((indicators-stack (!indicators-stack carousel-page))
         (indicators-row (!indicators-row carousel-page))
         (selected-item (get-selected-item indicators-row)))
    (set-visible-child-name indicators-stack
                            (get-string selected-item))))


;;;
;;; utils
;;;

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))

