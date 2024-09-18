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


(define-module (pages banners banners)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-banners>))


#;(g-export )


(define-class <adw-demo-page-banners> (<adw-bin>)
  ;; child-id slot(s)
  (banner #:accessor !banner #:child-id "banner")
  (button-label-row #:accessor !button-label-row #:child-id "button-label-row")
  ;; slot(s)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/banners/banners-ui.ui")
  #:child-ids '("banner"
                "button-label-row")
  #:g-signal `(add-toast	;; name
               none		;; return-type	
               (,<adw-toast>)	;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-banners>) initargs)
  (next-method)

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((demo-window (get-root self))
                    (toast-overlay (slot-ref demo-window 'toast-overlay)))
               (add-toast toast-overlay toast))))
  
  (install-actions self))

(define-method (add-toast (self <adw-demo-page-banners>) toast)
  (emit self 'add-toast toast))

(define (install-actions demo-page-banners)
  (let ((action-map (make <g-simple-action-group>))
        (a-activate (make <g-simple-action> #:name "activate"))
        (a-toggle-button (make <g-simple-action> #:name "toggle-button")))

    (add-action action-map a-activate)
    (connect a-activate
             'activate
             (lambda (s-action g-variant)
               (banner/activate demo-page-banners)))

    (add-action action-map a-toggle-button)
    (connect a-toggle-button
             'activate
             (lambda (s-action g-variant)
               (banner/toggle-button demo-page-banners)))

    (insert-action-group demo-page-banners
                         "banner"
                         action-map)))

(define (banner/activate demo-page-banners)
  (add-toast demo-page-banners
             (make <adw-toast> #:title "Banner action triggered")))

(define (banner/toggle-button demo-page-banners)
  (let* ((self demo-page-banners)
         (button-label (get-button-label (!banner demo-page-banners))))
    (if (string-null? button-label)
        (set-button-label (!banner self)
                          (get-text (!button-label-row self)))
        (set-button-label (!banner self) #f))))


;;;
;;; callback
;;;


;;;
;;; utils
;;;
