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


(define %page-1
  '(object (@ (class "AdwViewStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) _World)
     (property (@ (name "name")) page-1)
     (property (@ (name "icon-name")) clock-world-symbolic)
     (property (@ (name "use-underline")) True)
     (property (@ (name "child"))
       (object (@ (class "GtkLabel"))
         (property (@ (name "label")
                      (translatable "yes")) World)
         (property (@ (name "margin-top")) 24)
         (property (@ (name "margin-bottom")) 24)
         (property (@ (name "margin-start")) 24)
         (property (@ (name "margin-end")) 24)))))

(define %page-2
  '(object (@ (class "AdwViewStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) _Alarm)
     (property (@ (name "name")) page-2)
     (property (@ (name "icon-name")) clock-alarm-symbolic)
     (property (@ (name "use-underline")) True)
     (property (@ (name "child"))
       (object (@ (class "GtkLabel"))
         (property (@ (name "label")
                      (translatable "yes")) Alarm)
         (property (@ (name "margin-top")) 24)
         (property (@ (name "margin-bottom")) 24)
         (property (@ (name "margin-start")) 24)
         (property (@ (name "margin-end")) 24)))))

(define %page-3
  '(object (@ (class "AdwViewStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) _Stopwatch)
     (property (@ (name "name")) page-3)
     (property (@ (name "icon-name")) clock-stopwatch-symbolic)
     (property (@ (name "use-underline")) True)
     (property (@ (name "badge-number")) 3)
     (property (@ (name "needs-attention")) True)
     (property (@ (name "child"))
       (object (@ (class "GtkLabel"))
         (property (@ (name "label")
                      (translatable "yes")) Stopwatch)
         (property (@ (name "margin-top")) 24)
         (property (@ (name "margin-bottom")) 24)
         (property (@ (name "margin-start")) 24)
         (property (@ (name "margin-end")) 24)))))

(define %page-4
  '(object (@ (class "AdwViewStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Tim_er)
     (property (@ (name "name")) page-4)
     (property (@ (name "icon-name")) clock-timer-symbolic)
     (property (@ (name "use-underline")) True)
     (property (@ (name "child"))
       (object (@ (class "GtkLabel"))
         (property (@ (name "label")
                      (translatable "yes")) Timer)
         (property (@ (name "margin-top")) 24)
         (property (@ (name "margin-bottom")) 24)
         (property (@ (name "margin-start")) 24)
         (property (@ (name "margin-end")) 24)))))

(define %view-switcher-demo-dialog
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwViewSwitcherDemoDialog")
                 (parent "AdwDialog"))
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 200)
      (property (@ (name "content-width")) 640)
      (property (@ (name "content-height")) 320)
      (property (@ (name "title")
                   (translatable "yes")) "AdwViewSwitcher Demo")
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar")
                       (id "header-bar"))
              (property (@ (name "title-widget"))
                (object (@ (class "AdwViewSwitcher")
                           (id "switcher"))
                  (property (@ (name "stack")) stack)
                  (property (@ (name "policy")) wide)))))
          (property (@ (name "content"))
            (object (@ (class "AdwViewStack")
                         (id "stack"))
              (child ,%page-1)
              (child ,%page-2)
              (child ,%page-3)
              (child ,%page-4)))
          (child (@ (type "bottom"))
            (object (@ (class "AdwViewSwitcherBar")
                       (id "switcher-bar"))
              (property (@ (name "stack")) stack)))))
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 500sp")
            (setter (@ (object "switcher-bar")
                       (property "reveal")) True)
            (setter (@ (object "header-bar")
                       (property "title-widget"))))))))


(define (make-ui)
  (sxml->ui %view-switcher-demo-dialog))
