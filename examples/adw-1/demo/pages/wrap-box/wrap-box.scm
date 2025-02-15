;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2025
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


(define-module (pages wrap-box wrap-box)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-wrap-box>))


#;(g-export )


(define-class <adw-demo-page-wrap-box> (<adw-bin>)
  ;; child-id slot(s)
  (wrap-box #:accessor !wrap-box #:child-id "wrap-box")
  (add-bt #:accessor !add-bt #:child-id "add-bt")
  ;; slot(s)
  (text #:accessor !text)
  (n-word #:accessor !n-word)
  (c-pos #:accessor !c-pos)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/wrap-box/wrap-box-ui.ui")
  #:child-ids '("wrap-box"
                "add-bt"))

(define-method (initialize (self <adw-demo-page-wrap-box>) initargs)
  (next-method)
  (let ((text (string-split %lorem-ipsum #\Space)))
    (mslot-set! self
                'text text
                'n-word (length text)
                'c-pos 0))
  (install-actions self)
  (prepopulate self))

(define-method (prepopulate  (self <adw-demo-page-wrap-box>))
  (do ((i 0
          (+ i 1)))
      ((= i 10))
    (wb/add-tag self)))


;;;
;;; install actions
;;;

(define-method (install-actions (self <adw-demo-page-wrap-box>))
  (let ((action-map (make <g-simple-action-group>))
        (a-add-tag (make <g-simple-action> #:name "add-tag")))

    (add-action action-map a-add-tag)
    (connect a-add-tag
             'activate
             (lambda (s-action g-variant)
               (wb/add-tag self)))

    (insert-action-group self
                         "wb"
                         action-map)))

(define-method (wb/add-tag (self <adw-demo-page-wrap-box>))
  (let ((wrap-box (!wrap-box self))
        (last-tag (get-prev-sibling (!add-bt self)))
        (tag (make <gtk-box>
               #:orientation 'horizontal
               #:spacing 0
               #:hexpand #f))
        (label (make <gtk-label>
                 #:label (list-ref (!text self) (!c-pos self))
                 #:xalign 0
                 #:ellipsize 'end
                 #:hexpand #t))
        (close-bt (make <gtk-button>
                    #:icon-name "window-close-symbolic")))
    (add-css-class tag "tag")
    (add-css-class close-bt "flat")
    (add-css-class close-bt "circular")
    (append tag label)
    (append tag close-bt)

    (connect close-bt
             'clicked
             (lambda (bt)
               (remove-tag-cb wrap-box tag)))

    (insert-child-after wrap-box tag last-tag)
    (set! (!c-pos self)
          (modulo (+ (!c-pos self) 1) (!n-word self)))))


;;;
;;; callback
;;;

(define (remove-tag-cb wrap-box tag)
  (remove wrap-box tag))
  

;;;
;;; utils
;;;

(define %lorem-ipsum
  "Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit Sed Do Eiusmod Tempor Incididunt Ut Labore Et Dolore Magnam Aliquam Quaerat Voluptatem Ut Enim Aeque Doleamus Animo Cum Corpore Dolemus Fieri Tamen Permagna Accessio Potest Si Aliquod Aeternum Ullus Investigandi Veri Nisi Inveneris Et Quaerendi Defatigatio Turpis Est Cum Esset Accusata Et Vituperata Ab Hortensio Qui Liber Cum Et Mortem Contemnit Qua Qui Est Imbutus Quietus Esse Numquam Potest Praeterea Bona Praeterita Grata Recordatione Renovata Delectant Est Autem Situm In")
