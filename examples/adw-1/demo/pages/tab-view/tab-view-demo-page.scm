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


(define-module (pages tab-view tab-view-demo-page)
  #:use-module (ice-9 match)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-tab-view-demo-page>))


(g-export !icon?
          !loading?
          !needs-attention?
          !indicator?
          !muted?

          duplicate
          toggle-enable-icon
          refresh-icon
          toggle-enable-loading
          toggle-enable-needs-attention
          toggle-enable-indicator
          toggle-muted
          get-indicator-icon
          get-indicator-tooltip)


(define-class <adw-tab-view-demo-page> (<adw-bin>)
  ;; g-object (new) properties
  (title #:g-param `(string
                     #:default #f)
         #:accessor !title
         #:init-keyword #:title)
  (icon #:g-param `(object
                       #:type ,<g-icon>)
        #:accessor !icon
        #:init-keyword #:icon)
  ;; child-id slot(s)
  (title-entry #:child-id "title-entry" #:accessor !title-entry)
  ;; slot(s)
  (last-icon #:accessor !last-icon
             #:init-keyword #:last-icon #:init-value #f)
  (icon? #:accessor !icon?
         #:init-keyword #:icon? #:init-value #t)
  (loading? #:accessor !loading?
            #:init-keyword #:loading? #:init-value #f)
  (needs-attention? #:accessor !needs-attention?
            #:init-keyword #:needs-attention? #:init-value #f)
  (indicator? #:accessor !indicator?
              #:init-keyword #:indicator? #:init-value #f)
  (muted? #:accessor !muted?
          #:init-keyword #:muted? #:init-value #f)  ;; which indicator icon
  (color #:accessor !color #:init-value 0)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/tab-view/tab-view-demo-page-ui.ui")
  #:child-ids '("title-entry"))

(define-method (initialize (self <adw-tab-view-demo-page>) initargs)
  (let ((last-icon (get-keyword #:last-icon initargs #f)))
    (next-method)

    (bind-properties self)

    (unless last-icon
      ;; making a new instance, not a duplicate
      (set! (!icon self) (get-random-icon))
      (set! (!last-icon self) (!icon self)))
    (set-color self (get-random-color))))

(define-method (set-color (self <adw-tab-view-demo-page>) a-color)
  (let ((color (!color self)))
    (unless (= color a-color)
      (when (> color 0)
        (remove-css-class self
                          (format #f "tab-page-color-~A" color)))
      (when (> a-color 0)
        (add-css-class self
                       (format #f "tab-page-color-~A" a-color))))))

(define-method (duplicate (self <adw-tab-view-demo-page>))
  (make <adw-tab-view-demo-page>
    #:title (!title self)
    #:icon (!icon self)
    #:last-icon (!last-icon self)
    #:icon? (!icon? self)
    #:loading? (!loading? self)
    #:needs-attention? (!needs-attention? self)
    #:indicator? (!indicator? self)
    #:muted? (!muted? self)))

(define-method (toggle-enable-icon (self <adw-tab-view-demo-page>))
  (if (!icon? self)
      (begin
        (set! (!icon self) #f)
        (set! (!icon? self) #f))
      (begin
        (set! (!icon self) (!last-icon self))
        (set! (!icon? self) #t))))

(define-method (refresh-icon (self <adw-tab-view-demo-page>))
  (set! (!icon self) (get-random-icon))
  (set! (!last-icon self) (!icon self)))

(define-method (toggle-enable-loading (self <adw-tab-view-demo-page>))
  (let ((loading? (not (!loading? self))))
    (set! (!loading? self) loading?)
    loading?))

(define-method (toggle-enable-needs-attention (self <adw-tab-view-demo-page>))
  (let ((needs-attention? (not (!needs-attention? self))))
    (set! (!needs-attention? self) needs-attention?)
    needs-attention?))

(define-method (toggle-enable-indicator (self <adw-tab-view-demo-page>))
  (set! (!indicator? self) (not (!indicator? self))))

(define-method (toggle-muted (self <adw-tab-view-demo-page>))
  (set! (!muted? self) (not (!muted? self))))

(define-method (get-indicator-icon (self <adw-tab-view-demo-page>))
  (if (!muted? self)
      (g-themed-icon-new "tab-audio-muted-symbolic")
      (g-themed-icon-new "tab-audio-playing-symbolic")))

(define-method (get-indicator-tooltip (self <adw-tab-view-demo-page>))
  (if (!muted? self)
      "Unmute Tab"
      "Mute Tab"))


;;;
;;; bind properties
;;;

(define (bind-properties tab-view-demo-page)
  (bind-property tab-view-demo-page
                 "title"
                 (!title-entry tab-view-demo-page)
                 "text"
                 '(sync-create bidirectional)))


;;;
;;; icon
;;;

(define get-icon-names #f)

(let ((%icon-names '()))
  (set! get-icon-names
        (lambda (theme)
          (match %icon-names
            (()
             (let ((icon-names (gtk-icon-theme-get-icon-names theme)))
               (set! %icon-names icon-names)
               icon-names))
            (else
             %icon-names)))))

(define (get-random-icon)
  (let* ((display (gdk-display-get-default))
         (theme (gtk-icon-theme-get-for-display display))
         (icon-names (get-icon-names theme))
         (n-icon (length icon-names))
         (icon (list-ref icon-names (random n-icon))))
    (g-themed-icon-new icon)))


;;;
;;; color
;;;

(define %n-colors 8)

(define (get-random-color)
  (+ (random %n-colors) 1))
