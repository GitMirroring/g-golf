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

(define %sidebar-headerbar
  '(object (@ (class "AdwHeaderBar"))
     (child (@ (type "start"))
       (object (@ (class "GtkButton")
                  (id "color-scheme-button"))))
     (child (@ (type "end"))
       (object (@ (class "GtkMenuButton"))
         (property (@ (name "tooltip-text")
                      (translatable "yes")) "Main Menu")
         (property (@ (name "menu-model")) primary-menu)
         (property (@ (name "icon-name")) open-menu-symbolic)
         (property (@ (name "primary")) True)))))

(define %welcome-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Welcome)
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageWelcome"))))))

(define %navigation-view
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Navigation View")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageNavigationView"))))))

(define %style-classes
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Style Classes")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageStyleClasses"))))))

(define %sidebar
  `(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (bind-source "AdwDemoWindow")
                  (bind-property "title")
                  (bind-flags "sync-create")))
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           ,%sidebar-headerbar)
         (property (@ (name "content"))
           (object (@ (class "GtkStackSidebar"))
             (property (@ (name "stack")) stack)))))))

(define %content
  `(object (@ (class "AdwNavigationPage"))
     ;; libadwaita-1-0:amd64 1.4~rc-1 complains if none, despite
     ;; its AdwHeaderBar show-title property set to false ...
     (property (@ (name "title")) "Bluefox") ;; fake title
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))
             (property (@ (name "show-title")) False)))
         (property (@ (name "content"))
           (object (@ (class "GtkStack")
                      (id "stack"))
             (property (@ (name "vhomogeneous")) False)
             ;; signal - notify::visible-child ...
             (child ,%welcome-page)
             (child ,%navigation-view)
             (child ,%style-classes)))))))

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
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 200)
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 500sp")
            (setter (@ (object "split-view")
                       (property "collapsed")) True)))
      (property (@ (name "content"))
        (object (@ (class "AdwToastOverlay")
                   (id "toast-overlay"))
          (property (@ (name "child"))
            (object (@ (class "AdwNavigationSplitView")
                       (id "split-view"))
              (property (@ (name "min-sidebar-width")) 240)
              (property (@ (name "sidebar"))
                ,%sidebar)
              (property (@ (name "content"))
                ,%content))))))))


(define (make-ui)
  (sxml->ui %window))
