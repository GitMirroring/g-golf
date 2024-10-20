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


(define %adw-layout-wide
  '(object (@ (class "AdwLayout"))
     (property (@ (name "name")) wide)
     (property (@ (name "content"))
       (object (@ (class "AdwOverlaySplitView"))
         (property (@ (name "sidebar"))
           (object (@ (class "AdwToolbarView"))
             (child (@ (type "top"))
               (object (@ (class "AdwHeaderBar"))
                 (property (@ (name "show-title")) False)))
             (property (@ (name "content"))
               (object (@ (class "AdwLayoutSlot"))
                 (property (@ (name "id")) sidebar)))))
         (property (@ (name "content"))
           (object (@ (class "AdwToolbarView"))
             (child (@ (type "top"))
               (object (@ (class "AdwHeaderBar"))
                 (property (@ (name "show-title")) False)))
             (property (@ (name "content"))
               (object (@ (class "AdwLayoutSlot"))
                 (property (@ (name "id")) content)))))))))

(define %adw-layout-narrow
  '(object (@ (class "AdwLayout"))
     (property (@ (name "name")) narrow)
     (property (@ (name "content"))
       (object (@ (class "AdwToolbarView"))
         (property (@ (name "bottom-bar-style")) raised)
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))
             (property (@ (name "show-title")) False)))
         (property (@ (name "content"))
           (object (@ (class "AdwLayoutSlot"))
             (property (@ (name "id")) content)))
         (child (@ (type "bottom"))
           (object (@ (class "AdwLayoutSlot"))
             (property (@ (name "id")) sidebar)
             (property (@ (name "height-request")) 100)))))))

(define %multi-layout-demo-dialog
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwMultiLayoutDemoDialog")
                 (parent "AdwDialog"))
      (property (@ (name "title")
                   (translatable "yes")) "Style Classes")
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 200)
      (property (@ (name "content-width")) 800)
      (property (@ (name "content-height")) 600)
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 500sp")
            (setter (@ (object "view")
                       (property "layout-name")) narrow)))
      (property (@ (name "child"))
        (object (@ (class "AdwMultiLayoutView")
                   (id "view"))
          (child ,%adw-layout-wide)
          (child ,%adw-layout-narrow)
          (child (@ (type "sidebar"))
             (object (@ (class "GtkLabel"))
               (property (@ (name "label")) Sidebar)
               (style (class (@ (name "title-1"))))))
          (child (@ (type "content"))
             (object (@ (class "GtkLabel"))
               (property (@ (name "label")) Content)
               (style (class (@ (name "title-1")))))))))))

(define (make-ui)
  (sxml->ui %multi-layout-demo-dialog))
