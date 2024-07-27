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


(define-module (pages toasts toasts)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-toasts>))


(g-export undo)


(define-class <adw-demo-page-toasts> (<adw-bin>)
  ;; child-id slot(s)
  ;; slot(s)
  (undo-toast #:accessor !undo-toast #:init-value #f)
  (toast-undo-items #:accessor !toast-undo-items #:init-value 0)
  (toast-action-group #:accessor !toast-action-group)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/toasts/toasts-ui.ui")
  #:g-signal `(add-toast	;; name
               none		;; return-type	
               (,<adw-toast>)	;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-toasts>) initargs)
  (next-method)

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((demo-window (get-root self))
                    (toast-overlay (slot-ref demo-window 'toast-overlay)))
               (add-toast toast-overlay toast))))
  
  (install-actions self)
  (set-toast-action-enabled self "dismiss" #f))

(define-method (add-toast (self <adw-demo-page-toasts>) toast)
  (emit self 'add-toast toast))

(define %undo-title-1-fmt
  "Undoing deleting <span font_features='tnum=1'>~A</span> item...")

(define %undo-title-n-fmt
  "Undoing deleting <span font_features='tnum=1'>~A</span> items...")

(define-method (undo (self <adw-demo-page-toasts>))
  (let* ((toast-undo-items (!toast-undo-items self))
         (title (if (> toast-undo-items 1)
                    (format #f "~?" %undo-title-n-fmt (list toast-undo-items))
                    (format #f "~?" %undo-title-1-fmt (list toast-undo-items))))
         (toast (make <adw-toast> #:title title)))
    (set-priority toast 'high)
    (add-toast self toast)))

(define (install-actions demo-page-toasts)
  (let ((action-map (make <g-simple-action-group>))
        (a-add (make <g-simple-action> #:name "add"))
        (a-add-with-button (make <g-simple-action> #:name "add-with-button"))
        (a-add-with-long-title (make <g-simple-action>
                                 #:name "add-with-long-title"))
        (a-dismiss (make <g-simple-action> #:name "dismiss")))

    (add-action action-map a-add)
    (connect a-add
             'activate
             (lambda (s-action g-variant)
               (toast/add demo-page-toasts)))

    (add-action action-map a-add-with-button)
    (connect a-add-with-button
             'activate
             (lambda (s-action g-variant)
               (toast/add-with-button demo-page-toasts)))

    (add-action action-map a-add-with-long-title)
    (connect a-add-with-long-title
             'activate
             (lambda (s-action g-variant)
               (toast/add-with-long-title demo-page-toasts)))

    (add-action action-map a-dismiss)
    (connect a-dismiss
             'activate
             (lambda (s-action g-variant)
               (toast/dismiss demo-page-toasts)))

    (set! (!toast-action-group demo-page-toasts) action-map)
    (insert-action-group demo-page-toasts
                         "toast"
                         action-map)))

(define (toast/add demo-page-toasts)
  (add-toast demo-page-toasts
             (make <adw-toast> #:title "Simple Toast")))

(define %title-1-fmt
  "<span font_features='tnum=1'>~A</span> item deleted")

(define %title-n-fmt
  "<span font_features='tnum=1'>~A</span> items deleted")

(define (toast/add-with-button demo-page-toasts)
  (let* ((self demo-page-toasts)
         (undo-toast (!undo-toast self))
         (toast-undo-items (+ (!toast-undo-items self) 1)))
    (set! (!toast-undo-items self) toast-undo-items)
    (if undo-toast
        (let ((title (if (> toast-undo-items 1)
                         (format #f "~?" %title-n-fmt (list toast-undo-items))
                         (format #f "~?" %title-1-fmt (list toast-undo-items)))))
          (set-title undo-toast title)
          (add-toast self (g-object-ref undo-toast)))
        (let ((toast (make <adw-toast>
                       ;; (string-append "Lorem Ipsum" (G_ "deleted"))
                       #:title "Lorem Ipsum deleted")))
          (set! (!undo-toast self) toast)
          (set-priority toast 'high)
          (set-button-label toast "Undo") ;; (G_ "Undo")
          (set-action-name toast "toast.undo")
          (connect toast
                   'dismissed
                   (lambda (toast)
                     (dismissed-cb self)))
          (add-toast self toast)
          (set-toast-action-enabled self "dismiss" #t)))))

(define %long-title
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem.")

(define (toast/add-with-long-title demo-page-toasts)
  (add-toast demo-page-toasts
             (make <adw-toast> #:title %long-title)))

(define (toast/dismiss demo-page-toasts)
  (and=> (!undo-toast demo-page-toasts) dismiss))


;;;
;;; callback
;;;

(define (dismissed-cb demo-page-toasts)
  (let ((self demo-page-toasts))
    (mslot-set! self
                'undo-toast #f
                'toast-undo-items 0)
    (set-toast-action-enabled self "dismiss" #f)))


;;;
;;; utils
;;;

(define (set-toast-action-enabled demo-page-toasts name enabled?)
  (let* ((action-group (!toast-action-group demo-page-toasts))
         (action (lookup-action action-group name)))
    (and action
         (set-enabled action enabled?))))
