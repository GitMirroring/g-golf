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


(define %tab-menu
  '(menu (@ (id "tab-menu"))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "_Move to New Window")
         (attribute (@ (name "action")) tab.move-to-new-window))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) D_uplicate)
         (attribute (@ (name "action")) tab.duplicate)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "P_in Tab")
         (attribute (@ (name "action")) tab.pin)
         (attribute (@ (name "hidden-when")) action-disabled))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Unp_in Tab")
         (attribute (@ (name "action")) tab.unpin)
         (attribute (@ (name "hidden-when")) action-disabled)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) Icon)
         (attribute (@ (name "action")) "tab.icon"))
       (item
         (attribute (@ (name "label")
                       (translatable "yes"))"R_efresh Icon")
         (attribute (@ (name "action")) tab.refresh-icon)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) Loa_ding)
         (attribute (@ (name "action")) tab.loading))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Needs _Attention")
         (attribute (@ (name "action")) tab.needs-attention))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) Indicator)
         (attribute (@ (name "action")) tab.indicator)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Close _Other Tabs")
         (attribute (@ (name "action")) tab.close-other))
       (item
           (attribute (@ (name "label")
                         (translatable "yes")
                         (comments "Translators: \\“Close Tabs to the _Right\\” if you’re translating for a language that reads from right to left")) "Close Tabs to the _Left")
         (attribute (@ (name "action")) tab.close-before))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")
                       (comments "Translators: \\“Close Tabs to the _Left\\” if you’re translating for a language that reads from right to left")) "Close Tabs to the _Right")
         (attribute (@ (name "action")) tab.close-after)))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) _Close)
         (attribute (@ (name "action")) "tab.close")
         #;(attribute (@ (name "accel")) <Control>w)))))


(define %window-new-bt
  '(object (@ (class "GtkButton")
              (id "window-new-bt"))
     (property (@ (name "icon-name")) window-new-symbolic)
     (property (@ (name "tooltip-text")
                  (translatable "yes")) "New Window")
     (property (@ (name "action-name")) win.window-new)))

(define %narrow-overview-bt
  '(object (@ (class "AdwTabButton")
              (id "narrow-overview-bt"))
     (property (@ (name "visible")) False)
     (property (@ (name "view")) view)
     (property (@ (name "action-name")) overview.open)))

(define %overview-bt
  '(object (@ (class "GtkButton")
              (id "overview-bt"))
     (property (@ (name "icon-name")) view-grid-symbolic)
     (property (@ (name "tooltip-text")
                  (translatable "yes")) "View Open Tabs")
     (property (@ (name "action-name")) overview.open)))

(define %new-tab-bt
  '(object (@ (class "GtkButton")
              (id "tab-new-bt"))
     (property (@ (name "icon-name")) tab-new-symbolic)
     (property (@ (name "tooltip-text")
                  (translatable "yes")) "New Tab")
     (property (@ (name "action-name")) win.tab-new)))

(define %tab-overview
  `(object (@ (class "AdwTabOverview")
              (id "tab-overview"))
     (property (@ (name "view")) view)
     (property (@ (name "enable-new-tab")) True)
     ;; signal - extra-drag-drop - extra-drag-drop-cb - swapped
     ;; signal - create-tab - create-tab-cb - swapped
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (property (@ (name "top-bar-style")) raised)
         (child (@ (type "top"))
           (object (@ (class "GtkHeaderBar"))
             (child (@ (type "start")) ,%window-new-bt)
             (child (@ (type "end")) ,%narrow-overview-bt)
             (child (@ (type "end")) ,%overview-bt)
             (child (@ (type "end")) ,%new-tab-bt)))
         (child (@ (type "top"))
           (object (@ (class "AdwTabBar")
                      (id "tab-bar"))
             (property (@ (name "view")) view)
             ;; signal - extra-drag-drop - extra-drag-drop-cb - swapped
             ))
         (property (@ (name "content"))
           (object (@ (class "AdwTabView")
                      (id "view"))
             (property (@ (name "menu-model")) tab-menu)
             ;; signal - page-detached - page-detached-cb - swapped
             ;; signal - setup-menu - setup-menu-cb - swapped
             ;; signal - create-window - create-window-cb - swapped
             ;; signal - indicator-activated - indicator-activated-cb - swapped
             ))))))


(define %tab-view-demo-window
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwTabViewDemoWindow")
                 (parent "AdwWindow"))
      (property (@ (name "title")
                   (translatable "yes")) "Tab View Demo")
      (property (@ (name "default-width")) 800)
      (property (@ (name "default-height")) 600)
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 150)
      (property (@ (name "content"))
        ,%tab-overview)
      ;; apparently not permited, not sure why but ...
      #;(child
          (object (@ (class "GtkShortcutController"))
            (property (@ (name "scope")) managed)
            (child (@ (class "GtkShortcut"))
              (property (@ (name "trigger")) <Control>w)
              (property (@ (name "action")) "tab.close"))
            ))
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 600px")
            (setter (@ (object "narrow-overview-bt")
                       (property "visible")) True)
            (setter (@ (object "overview-bt")
                       (property "visible")) False)
            (setter (@ (object "tab-new-bt")
                       (property "visible")) False)
            (setter (@ (object "tab-bar")
                       (property "visible")) False))))
    ,%tab-menu))


(define (make-ui)
  (sxml->ui %tab-view-demo-window))
