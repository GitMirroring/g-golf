;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2025
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


(define %group-with-labels
  `(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Group with Labels")
     (child
         (object (@ (class "AdwToggleGroup"))
           (property (@ (name "valign")) center)
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "label")
                              (translatable "yes")) "24-hour")
                 (property (@ (name "name")) 24)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "label")
                              (translatable "yes")) "AM / PM")
                 (property (@ (name "name")) 12)))))))

(define %group-with-icons
  `(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Group with Icons")
     (child
         (object (@ (class "AdwToggleGroup"))
           (property (@ (name "valign")) center)
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "Grid View")
                 (property (@ (name "icon-name")) view-grid-symbolic)
                 (property (@ (name "name")) grid)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "List View")
                 (property (@ (name "icon-name")) view-list-symbolic)
                 (property (@ (name "name")) list)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "Dual View")
                 (property (@ (name "icon-name")) view-dual-symbolic)
                 (property (@ (name "name")) columns)))))))

(define %flat-group
  `(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Flat Group")
     (child
         (object (@ (class "AdwToggleGroup"))
           (property (@ (name "valign")) center)
           (style (class (@ (name "flat"))))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) Thumbnails)
                 (property (@ (name "icon-name")) view-grid-symbolic)
                 (property (@ (name "name")) thumbnails)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "List View")
                 (property (@ (name "icon-name")) format-justify-left-symbolic)
                 (property (@ (name "name")) outline)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) Bookmarks)
                 (property (@ (name "icon-name")) user-bookmarks-symbolic)
                 (property (@ (name "name")) bookmarks)))))))

(define %round-group
  `(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Round Group")
     (child
         (object (@ (class "AdwToggleGroup"))
           (property (@ (name "valign")) center)
           (style (class (@ (name "round"))))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "Picture Mode")
                 (property (@ (name "icon-name")) camera-photo-symbolic)
                 (property (@ (name "name")) picture)))
           (child
               (object (@ (class "AdwToggle"))
                 (property (@ (name "tooltip")
                              (translatable "yes")) "Recording Mode")
                 (property (@ (name "icon-name")) camera-video-symbolic)
                 (property (@ (name "name")) recording)))))))


(define %toggle-groups-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageToggleGroups")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "title")
                           (translatable "yes")) "Toggle Groups")
              (property (@ (name "description")
                           (translatable "yes")) "A group of toggle buttons")
              (property (@ (name "icon-name")) widget-toggle-group-symbolic)
              (property (@ (name "child"))
                (object (@ (class "AdwClamp"))
                  (property (@ (name "maximum-size")) 400)
                  (property (@ (name "tightening-threshold")) 300)
                  (property (@ (name "child"))
                    (object (@ (class "AdwPreferencesGroup"))
                      (child ,%group-with-labels)
                      (child ,%group-with-icons)
                      (child ,%flat-group)
                      (child ,%round-group))))))))))))


(define (make-ui)
  (sxml->ui %toggle-groups-page))
