;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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


(define %adw-combo-row
  '(object (@ (class "AdwComboRow")
              (id "transition-row"))
     (property (@ (name "title")
                  (translatable "yes")) "Transition Type")
     (property (@ (name "subtitle")
                  (translatable "yes")) "The type of transition to use when the leaflet adapts its size or when changing the visible child")
     ;; the binding is done in scheme, see (adw1-demo leaflet), as part
     ;; of the <adw-demo-page-leaflet>) initialize method
     #;(property (@ (name "selected")
                  (bind-source "AdwDemoPageLeaflet")
                  (bind-property "transition-type")
                  (bind-flags "sync-create|bidirectional")))
     (property (@ (name "model"))
       (object (@ (class "AdwEnumListModel"))
         (property (@ (name "enum-type")) AdwLeafletTransitionType)))))


(define %adw-action-row
  '(object (@ (class "AdwActionRow")
              (id "action-row"))
     (property (@ (name "title")
                  (translatable "yes")) "Go to the next page of the leaflet")
     (property (@ (name "use-underline")) True)
     (property (@ (name "activatable")) True)
     ;; signal - activated - swapped
     (child
         (object (@ (class "GtkImage"))
           (property (@ (name "icon-name")) go-next-symbolic)))))


(define %leaflet
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageLeaflet")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwStatusPage"))
          (property (@ (name "icon-name")) widget-leaflet-symbolic)
          (property (@ (name "title")
                       (translatable "yes")) Leaflet)
          (property (@ (name "description")
                       (translatable "yes")) "A widget showing either all its children or only one, depending on the available space. This window is using a leaflet, you can control it with the settings below.")
          (property (@ (name "child"))
            (object (@ (class "AdwClamp"))
              (property (@ (name "child"))
                (object (@ (class "AdwPreferencesGroup"))
                  (child ,%adw-combo-row)
                  (child ,%adw-action-row))))))))))


(define (make-ui)
  (sxml->ui %leaflet))


