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


(define %primary-menu
  '(menu (@ (id "primary-menu"))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) _Inspector)
         (attribute (@ (name "action")) app.inspector)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) _Preferences)
         (attribute (@ (name "action")) app.preferences))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) _"About Adwaita Demo")
         (attribute (@ (name "action")) app.about)))))

(define %header-bar-1
  '(object (@ (class "AdwHeaderBar"))
     (property (@ (name "show-end-title-buttons")
                  (bind-source "main-leaflet")
                  (bind-property "folded")
                  (bind-flags "sync-create")))
     (child (@ (type "start"))
       (object (@ (class "GtkButton")
                  (id "color-scheme-button"))))
     (child (@ (type "end"))
       (object (@ (class "GtkMenuButton"))
         (property (@ (name "menu-model")) primary-menu)
         (property (@ (name "icon-name")) open-menu-symbolic)
         (property (@ (name "primary")) True)))))

(define %stack-sidebar
  '(object (@ (class "GtkStackSidebar"))
     (property (@ (name "width-request")) 270)
     (property (@ (name "vexpand")) True)
     (property (@ (name "stack")) stack)))

(define %header-bar-2
  '(object (@ (class "AdwHeaderBar"))
     (property (@ (name "show-start-title-buttons")
                  (bind-source "main-leaflet")
                  (bind-property "folded")
                  (bind-flags "sync-create")))
     (property (@ (name "title-widget"))
       (object (@ (class "GtkBox"))))
     (child (@ (type "start"))
       (object (@ (class "GtkButton")
                  (id "main-go-previous"))
         (property (@ (name "valign")) center)
         (property (@ (name "tooltip-text")
                      (translatable "yes")) Back)
         (property (@ (name "icon-name")) go-previous-symbolic)
         (property (@ (name "visible")
                      (bind-source "main-leaflet")
                      (bind-property "folded")
                      (bind-flags "sync-create")))))))

(define %welcome-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Welcome)
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageWelcome"))))))

(define %leaflet-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Leaflet)
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageLeaflet")
                  (id "leaflet-page"))
         ;; signal - next-page ...
         ))))

(define %stack
  `(object (@ (class "GtkStack")
              (id "stack"))
     (property (@ (name "vexpand")) True)
     (property (@ (name "vhomogeneous")) False)
     ;; signal - notify::visible-child ... 
     (child ,%welcome-page)
     (child ,%leaflet-page)))

(define %main-leaflet
  `(object (@ (class "AdwLeaflet")
              (id "main-leaflet"))
     (property (@ (name "can-navigate-back")) True)
     (property (@ (name "transition-type")
                  (bind-source "leaflet-page")
                  (bind-property "transition-type")
                  (bind-flags "sync-create|bidirectional")))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "orientation")) vertical)
           (child ,%header-bar-1)
           (child ,%stack-sidebar)))
     (child
         (object (@ (class "AdwLeafletPage"))
           (property (@ (name "navigatable")) False)
           (property (@ (name "child"))
             (object (@ (class "GtkSeparator"))))))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "orientation")) vertical)
           (property (@ (name "hexpand")) True)
           (child ,%header-bar-2)
           (child ,%stack)))))

(define %header-bar-3
  '(object (@ (class "AdwHeaderBar"))
     (property (@ (name "title-widget"))
       (object (@ (class "GtkBox"))))
     (child (@ (type "start"))
       (object (@ (class "GtkButton")
                  (id "subpage-go-previous"))
         (property (@ (name "valign")) center)
         (property (@ (name "tooltip-text")
                      (translatable "yes")) Back)
         (property (@ (name "icon-name")) go-previous-symbolic)
         #;(property (@ (name "visible")
                      (bind-source "main-leaflet")
                      (bind-property "folded")
                      (bind-flags "sync-create")))))))

(define %status-page
  '(object (@ (class "AdwStatusPage"))
     (property (@ (name "vexpand")) True)
     (property (@ (name "title")
                  (translatable "yes")) Go Back)
     (property (@ (name "child"))
       (object (@ (class "GtkBox"))
         (property (@ (name "orientation")) vertical)
         (property (@ (name "halign")) center)
         (property (@ (name "spacing")) 12)
         (child
             (object (@ (class "GtkImage"))
               (property (@ (name "icon-name"))
                 gesture-touchscreen-swipe-back-symbolic)
               (property (@ (name "pixel-size")) 128)
               (style (class (@ (name "dim-label"))))))
         (child
             (object (@ (class "GtkImage"))
               (property (@ (name "icon-name"))
                 gesture-touchpad-swipe-back-symbolic)
               (property (@ (name "pixel-size")) 128)
               (style (class (@ (name "dim-label"))))))))))

(define %window
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    ,%primary-menu
    (template (@ (class "AdwDemoWindow")
                 (parent "AdwApplicationWindow"))
      (property (@ (name "title")
                   (translatable "yes")) "Adwaita Demo")
      (property (@ (name "default-width")) 800)
      (property (@ (name "default-height")) 576)
      (property (@ (name "content"))
        (object (@ (class "AdwToastOverlay")
                   (id "toast-overlay"))
          (property (@ (name "child"))
            (object (@ (class "AdwLeaflet")
                       (id "subpage-leaflet"))
              (property (@ (name "can-navigate-back")) True)
              (property (@ (name "width-request")) 360)
              (property (@ (name "can-unfold")) False)
              (property (@ (name "transition-type")
                           (bind-source "leaflet-page")
                           (bind-property "transition-type")
                           (bind-flags "sync-create|bidirectional")))
              (child ,%main-leaflet)
              (child
                  (object (@ (class "GtkBox"))
                    (property (@ (name "orientation")) vertical)
                    (child ,%header-bar-3)
                    (child ,%status-page))))))))))


(define (make-ui)
  (sxml->ui %window))
