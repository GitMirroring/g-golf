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


(define %headerbar
  '(object (@ (class "AdwHeaderBar"))
     (child (@ (type "start"))
       (object (@ (class "GtkToggleButton")
                  (id "view-sidebar-start-button"))
         (property (@ (name "icon-name")) view-sidebar-start-symbolic)
         (property (@ (name "tooltip-text")
                      (translatable "yes")) "Toggle Sidebar")
         (property (@ (name "active")) True)
         ;; bind property visible
         ;;   source start-button // active // sync-create
         ))
     (child (@ (type "end"))
       (object (@ (class "GtkToggleButton")
                  (id "view-sidebar-end-button"))
         (property (@ (name "icon-name")) view-sidebar-end-symbolic)
         (property (@ (name "tooltip-text")
                      (translatable "yes")) "Toggle Sidebar")
         ;; bind property active
         ;;   source view-sidebar-start-button // active // sync-create|bidirectional
         ;; bind property visible
         ;;   source end-button // active // sync-create
         ))))

(define %sidebar
  '(object (@ (class "AdwStatusPage"))
     (property (@ (name "title")
                  (translatable "yes")) Sidebar)
     (property (@ (name "child"))
       (object (@ (class "GtkBox"))
         (property (@ (name "orientation")) vertical)
         (property (@ (name "spacing")) 18)
         (property (@ (name "halign")) center)
         (child
             (object (@ (class "GtkToggleButton")
                        (id "start-button"))
               (property (@ (name "label")
                            (translatable "yes")) Start)
               (property (@ (name "can-shrink")) True)
               (property (@ (name "active")) True)
               ;; signal notify::active
               ;;   handler start_button_notify_active_cb // swapped yes
               (style (class (@ (name "pill"))))))
         (child
             (object (@ (class "GtkToggleButton")
                        (id "end-button"))
               (property (@ (name "label")
                            (translatable "yes")) End)
               (property (@ (name "can-shrink")) True)
               (property (@ (name "group")) start-button)
               (style (class (@ (name "pill"))))))))))

(define %content
  '(object (@ (class "AdwStatusPage"))
     (property (@ (name "title")
                  (translatable "yes")) Content)))

(define %overlay-splitview
  `(object (@ (class "AdwOverlaySplitView")
              (id "split-view"))
     ;; bind property show-sidebar
     ;;   source view-sidebar-start-button // active // sync-create|bidirectional
     (property (@ (name "sidebar"))
       ,%sidebar)
     (property (@ (name "content"))
       ,%content)))


(define %split-views-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwSplitViewsOverlayDialog")
                 (parent "AdwDialog"))
      (property (@ (name "title")
                   (translatable "yes")) "Overlay Split View")
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 200)
      (property (@ (name "content-width")) 640)
      (property (@ (name "content-height")) 480)
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 400sp")
            (setter (@ (object "split-view")
                       (property "collapsed")) True)))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (property (@ (name "top-bar-style")) raised)
          (child (@ (type "top"))
            ,%headerbar)
          (property (@ (name "content"))
            ,%overlay-splitview))))))


(define (make-ui)
  (sxml->ui %split-views-page))
