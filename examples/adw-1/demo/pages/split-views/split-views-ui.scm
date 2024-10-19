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


(define %split-views-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageSplitViews")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "icon-name")) widget-split-views-symbolic)
              (property (@ (name "title")
                           (translatable "yes")) "Split Views")
              (property (@ (name "description")
                           (translatable "yes")) "Widgets that display sidebar and content.")
              (property (@ (name "child"))
                (object (@ (class "GtkBox"))
                  (property (@ (name "orientation")) vertical)
                  (property (@ (name "spacing")) 18)
                  (property (@ (name "halign")) center)
                  (child
                      (object (@ (class "GtkButton")
                                 (id navigation-split-view-bt))
                        (property (@ (name "label")
                                     (translatable "yes")) "Navigation Split View")
                        (property (@ (name "can-shrink")) True)
                        (style (class (@ (name "pill"))))))
                  (child
                      (object (@ (class "GtkButton")
                                 (id overlay-split-view-bt))
                        (property (@ (name "label")
                                     (translatable "yes")) "Overlay Split View")
                        (property (@ (name "can-shrink")) True)
                        (style (class (@ (name "pill")))))))))))))))


(define (make-ui)
  (sxml->ui %split-views-page))
