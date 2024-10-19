;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023 - 2024
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


(define %welcome-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Welcome)
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageWelcome"))))))

(define %navigation-view-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Navigation View")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageNavigationView"))))))

(define %clamp-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Clamp")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageClamp"))))))

(define %lists-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Lists")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageLists"))))))

(define %view-switcher-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "View Switcher")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageViewSwitcher"))))))

(define %carousel-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Carousel")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageCarousel"))))))

(define %avatar-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Avatar")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageAvatar"))))))

(define %split-views-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Split Views")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageSplitViews"))))))

(define %tab-view-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Tab View")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageTabView"))))))

(define %buttons-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Buttons")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageButtons"))))))

(define %style-classes-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Style Classes")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageStyleClasses"))))))

(define %toasts-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Toasts")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageToasts")
                  (id "toasts-page"))
         ;; signal - add-toast - adw_toast_overlay_add_toast
         ;;        - toast-overlay - swapped
         ))))

#;(define %animations-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Animations")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageAnimations"))))))

(define %alerts-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Alert Dialog")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageAlerts"))
         ;; signal - add-toast - adw_toast_overlay_add_toast
         ;;        - toast-overlay - swapped
         ))))

(define %about-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "About Dialog")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageAbout"))))))

(define %banner-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Banner")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageBanner"))
         ;; signal - add-toast - adw_toast_overlay_add_toast
         ;;        - toast-overlay - swapped
         ))))

(define %bottom-sheets-page
  '(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Bottom Sheet")
     (property (@ (name "child"))
       (object (@ (class "AdwDemoPageBottomSheets"))))))

(define %adw-demo-window-sidebar
  `(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (bind-source "AdwDemoWindow")
                  (bind-property "title")
                  (bind-flags "sync-create")))
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))
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
         (property (@ (name "content"))
           (object (@ (class "GtkStackSidebar"))
             (property (@ (name "stack")) stack)))))))

(define %adw-demo-window-content
  `(object (@ (class "AdwNavigationPage")
              (id "content"))
     ;; Unless we set the AdwNavigationPage title to something, Adwaita
     ;; complains, even if if/when we set its AdwHeaderBar show-title
     ;; property set to false ...
     (property (@ (name "title")) "Hidden but ...") ;; fake title
     (property (@ (name "child"))
       (object (@ (class "GtkStack")
                  (id "stack"))
         (property (@ (name "vhomogeneous")) False)
         ;; signal - notify::visible-child ...
         (child ,%welcome-page)
         (child ,%navigation-view-page)
         (child ,%clamp-page)
         (child ,%lists-page)
         (child ,%view-switcher-page)
         (child ,%carousel-page)
         (child ,%avatar-page)
         (child ,%split-views-page)
         (child ,%tab-view-page)
         (child ,%buttons-page)
         (child ,%style-classes-page)
         (child ,%toasts-page)
         #;(child ,%animations-page)
         (child ,%alerts-page)
         (child ,%about-page)
         (child ,%banner-page)
         (child ,%bottom-sheets-page)))))

(define %adw-demo-window
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
                ,%adw-demo-window-sidebar)
              (property (@ (name "content"))
                ,%adw-demo-window-content))))))))


(define (make-ui)
  (sxml->ui %adw-demo-window))
