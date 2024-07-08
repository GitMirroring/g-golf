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

(define %sidebar
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) Sidebar)
     (property (@ (name "tag")) sidebar)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))
             (property (@ (name "show-title")) False)))
         (property (@ (name "content"))
           (object (@ (class "AdwStatusPage"))
             (property (@ (name "title")
                          (translatable "yes")) Sidebar)
             (property (@ (name "child"))
               (object (@ (class "GtkButton")
                          (id "button"))
                 (property (@ (name "label")
                              (translatable "yes")) "Open Content")
                 (property (@ (name "visible")) False)
                 (property (@ (name "halign")) center)
                 (property (@ (name "can-shrink")) True)
                 (property (@ (name "action-name")) navigation.push)
                 (property (@ (name "action-target")) "'content'")
                 (style (class (@ (name "pill"))))))))))))

(define %content
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) Content)
     (property (@ (name "tag")) content)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))
             (property (@ (name "show-title")) False)))
         (property (@ (name "content"))
           (object (@ (class "AdwStatusPage"))
             (property (@ (name "title")
                          (translatable "yes")) Content)))))))

(define %split-views-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwSplitViewsNavigationDialog")
                 (parent "AdwDialog"))
      (property (@ (name "title")
                   (translatable "yes")) "Navigation Split View")
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 200)
      (property (@ (name "content-width")) 640)
      (property (@ (name "content-height")) 480)
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 400sp")
            (setter (@ (object "split-view")
                       (property "collapsed")) True)
            (setter (@ (object "button")
                       (property "visible")) True)))
      (property (@ (name "child"))
        (object (@ (class "AdwNavigationSplitView")
                   (id "split-view"))
          (property (@ (name "sidebar"))
            ,%sidebar)
          (property (@ (name "content"))
            ,%content))))))


(define (make-ui)
  (sxml->ui %split-views-page))
