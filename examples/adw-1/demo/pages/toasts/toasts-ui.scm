;; -*- mode: sxml-ui; coding: utf-8 -*-

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


(use-modules (g-golf support sxml))


(define %action-row-1
  '(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Simple Toast")
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Show)
           (property (@ (name "valign")) center)
            (property (@ (name "action-name")) toast.add)))))

(define %action-row-2
  '(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Toast With an Action")
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) user-trash-symbolic)
           (property (@ (name "valign")) center)
           (property (@ (name "action-name")) toast.dismiss)
           (style (class (@ (name "flat"))))))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Show)
           (property (@ (name "valign")) center)
           (property (@ (name "action-name")) toast.add-with-button)))))

(define %action-row-3
  '(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Toast With a Long Title")
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Show)
           (property (@ (name "valign")) center)
            (property (@ (name "action-name")) toast.add-with-long-title)))))


(define %toasts-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageToasts")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "icon-name")) widget-toast-symbolic)
              (property (@ (name "title")
                           (translatable "yes")) Toasts)
              (property (@ (name "description")
                           (translatable "yes")) "Transient in-app notifications.")
              (property (@ (name "child"))
                (object (@ (class "AdwClamp"))
                  (property (@ (name "maximum-size")) 400)
                  (property (@ (name "tightening-threshold")) 300)
                  (property (@ (name "child"))
                    (object (@ (class "AdwPreferencesGroup"))
                      (child ,%action-row-1)
                      (child ,%action-row-2)
                      (child ,%action-row-3))))))))))))


(define (make-ui)
  (sxml->ui %toasts-page))
