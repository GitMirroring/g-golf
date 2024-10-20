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


(define %sample-menu
  '(menu (@ (id "sample-menu"))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 1"))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 2"))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 3")))))


(define %adw-split-button-1
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "icon-name")) document-open-symbolic)
     (property (@ (name "menu-model")) sample-menu)
     (property (@ (name "tooltip-text")
                  (translatable "yes")) Open)
     (layout
       (property (@ (name "column")) 0)
       (property (@ (name "row")) 0))))

(define %adw-split-button-2
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "icon-name")) document-open-symbolic)
     (property (@ (name "menu-model")) sample-menu)
     (property (@ (name "tooltip-text")
                  (translatable "yes")) Open)
     (style (class (@ (name "flat"))))
     (layout
       (property (@ (name "column")) 0)
       (property (@ (name "row")) 1))))

(define %adw-split-button-3
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "label")
                  (translatable "yes")) _Open)
     (property (@ (name "use-underline")) True)
     (property (@ (name "can-shrink")) True)
     (property (@ (name "menu-model")) sample-menu)
     (layout
       (property (@ (name "column")) 1)
       (property (@ (name "row")) 0))))

(define %adw-split-button-4
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "label")
                  (translatable "yes")) _Open)
     (property (@ (name "use-underline")) True)
     (property (@ (name "can-shrink")) True)
     (property (@ (name "menu-model")) sample-menu)
     (style (class (@ (name "flat"))))
     (layout
       (property (@ (name "column")) 1)
       (property (@ (name "row")) 1))))

(define %adw-split-button-5
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "child"))
       (object (@ (class "AdwButtonContent"))
           (property (@ (name "icon-name")) document-open-symbolic)
           (property (@ (name "label")
                        (translatable "yes")) _Open)
           (property (@ (name "use-underline")) True)
           (property (@ (name "can-shrink")) True)))
     (property (@ (name "menu-model")) sample-menu)
     (layout
       (property (@ (name "column")) 2)
       (property (@ (name "row")) 0))))

(define %adw-split-button-6
  '(object (@ (class "AdwSplitButton"))
     (property (@ (name "child"))
       (object (@ (class "AdwButtonContent"))
           (property (@ (name "icon-name")) document-open-symbolic)
           (property (@ (name "label")
                        (translatable "yes")) _Open)
           (property (@ (name "use-underline")) True)
           (property (@ (name "can-shrink")) True)))
     (property (@ (name "menu-model")) sample-menu)
     (style (class (@ (name "flat"))))     
     (layout
       (property (@ (name "column")) 2)
       (property (@ (name "row")) 1))))


(define %buttons-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageButtons")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "title")
                           (translatable "yes")) Buttons)
              (property (@ (name "description")
                           (translatable "yes")) "Button helper widgets")
              (property (@ (name "child"))
                (object (@ (class "AdwClamp"))
                  (property (@ (name "maximum-size")) 400)
                  (property (@ (name "tightening-threshold")) 300)
                  (property (@ (name "child"))
                    (object (@ (class "GtkBox"))
                      (property (@ (name "orientation")) vertical)
                      (child
                          (object (@ (class "GtkGrid"))
                            (property (@ (name "halign")) center)
                            (property (@ (name "column-spacing")) 12)
                            (property (@ (name "row-spacing")) 12)
                            (child ,%adw-split-button-1)
                            (child ,%adw-split-button-2)
                            (child ,%adw-split-button-3)
                            (child ,%adw-split-button-4)
                            (child ,%adw-split-button-5)
                            (child ,%adw-split-button-6))))))))))))
        ,%sample-menu))


(define (make-ui)
  (sxml->ui %buttons-page))
