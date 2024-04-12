;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023, 2024
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
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Page 1")
     (property (@ (name "tag")) page-1)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "GtkBox"))
             (property (@ (name "halign")) center)
             (property (@ (name "valign")) center)
             (property (@ (name "orientation")) vertical)
             (property (@ (name "spacing")) 18)
         (child
             (object (@ (class "GtkButton")
                        (id "page-1-button-1"))
               (property (@ (name "label")
                            (translatable "yes")) "Open Page 2")
               (property (@ (name "can-shrink")) True)
               (property (@ (name "action-name")) navigation.push)
               (property (@ (name "action-target")) "'page-2'")
               (style (class (@ (name "pill"))))))
         (child
             (object (@ (class "GtkButton")
                        (id "page-1-button-2"))
               (property (@ (name "label")
                            (translatable "yes")) "Open Page 3")
               (property (@ (name "can-shrink")) True)
               (property (@ (name "action-name")) navigation.push)
               (property (@ (name "action-target")) "'page-3'")
               (style (class (@ (name "pill"))))))))))))


(define %page-2
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Page 2")
     (property (@ (name "tag")) page-2)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "GtkButton")
                      (id "page-2-button"))
               (property (@ (name "label")
                            (translatable "yes")) "Open Page 4")
               (property (@ (name "halign")) center)
               (property (@ (name "valign")) center)
               (property (@ (name "can-shrink")) True)
               (property (@ (name "action-name")) navigation.push)
               (property (@ (name "action-target")) "'page-4'")
               (style (class (@ (name "pill"))))))))))


(define %page-3
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Page 3")
     (property (@ (name "tag")) page-3)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "GtkLabel"))
               (property (@ (name "label")
                            (translatable "yes")) "Page 3")
               (property (@ (name "valign")) center)
               (property (@ (name "ellipsize")) end)
               (style (class (@ (name "title-1"))))))))))


(define %page-4
  '(object (@ (class "AdwNavigationPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Page 4")
     (property (@ (name "tag")) page-4)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "GtkButton")
                      (id "page-4-button"))
               (property (@ (name "label")
                            (translatable "yes")) "Open Page 3")
               (property (@ (name "halign")) center)
               (property (@ (name "valign")) center)
               (property (@ (name "can-shrink")) True)
               (property (@ (name "action-name")) navigation.push)
               (property (@ (name "action-target")) "'page-3'")
               (style (class (@ (name "pill"))))))))))


(define %navigation-view-demo-dialog
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwNavigationViewDemoDialog")
                 (parent "AdwDialog"))
      (property (@ (name "width-request")) 360)
      (property (@ (name "content-width")) 360)
      (property (@ (name "content-height")) 360)
      (property (@ (name "title")
                   (translatable "yes")) "AdwNavigationView Demo")
      (property (@ (name "child"))
        (object (@ (class "AdwNavigationView"))
          (child ,%page-1)
          (child ,%page-2)
          (child ,%page-3)
          (child ,%page-4))))))


(define (make-ui)
  (sxml->ui %navigation-view-demo-dialog))
