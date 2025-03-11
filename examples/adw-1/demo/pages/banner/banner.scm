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


(define-module (pages banner banner)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-banner>))


#;(g-export )


(define-class <adw-demo-page-banner> (<adw-bin>)
  ;; child-id slot(s)
  (banner #:accessor !banner #:child-id "banner")
  (button-label-row #:accessor !button-label-row #:child-id "button-label-row")
  (button-style-row #:accessor !button-style-row #:child-id "button-style-row")
  ;; slot(s)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/banner/banner-ui.ui")
  #:child-ids '("banner"
                "button-label-row"
                "button-style-row")
  #:g-signal `(add-toast	;; name
               none		;; return-type	
               (,<adw-toast>)	;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-banner>) initargs)
  (next-method)

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((demo-window (get-root self))
                    (toast-overlay (slot-ref demo-window 'toast-overlay)))
               (add-toast toast-overlay toast))))
  
  (connect (!button-label-row self)
           'notify::text
           (lambda (. args)
             (update-button-cb self)))

  (connect (!button-label-row self)
           'notify::editable
           (lambda (. args)
             (update-button-cb self)))

  (connect (!button-style-row self)
           'notify::active
           (lambda (. args)
             (button-style-cb self)))

  (install-actions self)
  ;; the following shouldn't be necessary, as things are properly set in
  ;; the banner-ui.scm module, both the banner editable text and the
  ;; editable property binding, but for some misterious reasons, unless
  ;; I actually do this call, the banner button is not visible.
  (set-button-label (!banner self)
                    (get-text (!button-label-row self))))


;;;
;;; install actions
;;;

(define-method (add-toast (self <adw-demo-page-banner>) toast)
  (emit self 'add-toast toast))

(define (install-actions demo-page-banner)
  (let ((action-map (make <g-simple-action-group>))
        (a-activate (make <g-simple-action> #:name "activate")))

    (add-action action-map a-activate)
    (connect a-activate
             'activate
             (lambda (s-action g-variant)
               (banner/activate demo-page-banner)))

    (insert-action-group demo-page-banner
                         "banner"
                         action-map)))

(define (banner/activate demo-page-banner)
  (add-toast demo-page-banner
             (make <adw-toast> #:title "Banner action triggered")))


;;;
;;; callback
;;;

(define (update-button-cb demo-page-banner)
  (let* ((self demo-page-banner)
         (button-label-row (!button-label-row self))
         (editable? (get-editable button-label-row)))
    (if editable?
        (set-button-label (!banner self)
                          (get-text button-label-row))
        (set-button-label (!banner self) #f))))

(define (button-style-cb demo-page-banner)
  (let* ((self demo-page-banner)
         (button-style-row (!button-style-row self))
         (active? (get-active button-style-row)))
    (if active?
        (set-button-style (!banner self) 'suggested)
        (set-button-style (!banner self) 'default))))


;;;
;;; utils
;;;
