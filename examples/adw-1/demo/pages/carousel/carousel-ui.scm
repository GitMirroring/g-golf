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


(define %empty-box
  '(object (@ (class "GtkBox")
              (id "empty-box"))))

(define %page-0
  '(object (@ (class "AdwStatusPage"))
     (property (@ (name "icon-name")) widget-carousel-symbolic)
     (property (@ (name "title")
                  (translatable "yes")) Carousel)
     (property (@ (name "description")
                  (translatable "yes")) "A widget for paginated scrolling.")
     (property (@ (name "vexpand")) True)))

(define %orientation-row
  '(object (@ (class "AdwComboRow")
              (id "orientation-row"))
     (property (@ (name "title")
                  (translatable "yes")) Orientation)
     ;; signal notify::selected
     ;;   handler notify_orientation_cb // swapped yes
     (property (@ (name "model"))
       (object (@ (class "AdwEnumListModel"))
         (property (@ (name "enum-type")) GtkOrientation)))
     ;; property expression
     ;;   name expression // closure get_orientation_name
     ))

(define %indicators-row
  '(object (@ (class "AdwComboRow")
              (id "indicators-row"))
     (property (@ (name "title")
                  (translatable "yes")) "Page Indicators")
     ;; signal notify::selected
     ;;   handler notify_indicators_cb // swapped yes
     (property (@ (name "model"))
       (object (@ (class "GtkStringList"))
         (items
          (item dots)
          (item lines))))
     ;; property expression
     ;;   name expression // closure get_indicators_name
     ))

(define %scroll-wheel
  '(object (@ (class "AdwSwitchRow")
              (id "scroll-wheel"))
     (property (@ (name "title")
                  (translatable "yes")) "Scroll Wheel")
     (property (@ (name "active")) True)))

(define %long-swipes
  '(object (@ (class "AdwSwitchRow")
              (id "long-swipes"))
     (property (@ (name "title")
                  (translatable "yes")) "Long Swipes")))

(define %page-1
  `(object (@ (class "AdwClamp"))
     (property (@ (name "margin-bottom")) 32)
     (property (@ (name "margin-start")) 12)
     (property (@ (name "margin-end")) 12)
     (property (@ (name "maximum-size")) 400)
     (property (@ (name "tightening-threshold")) 300)
     (property (@ (name "valign")) center)
     (property (@ (name "child"))
       (object (@ (class "AdwPreferencesGroup"))
         (child ,%orientation-row)
         (child ,%indicators-row)
         (child ,%scroll-wheel)
         (child ,%long-swipes)))))

(define %page-2
  '(object (@ (class "AdwStatusPage"))
     (property (@ (name "title")
                  (translatable "yes")) "Another Page")
     (property (@ (name "hexpand")) True)
     (property (@ (name "child"))
       (object (@ (class "GtkButton")
                  (id "return-bt"))
         (property (@ (name "label")
                      (translatable "yes")) "_Return to the First Page")
         (property (@ (name "can-shrink")) True)
         (property (@ (name "use-underline")) True)
         (property (@ (name "halign")) center)
         ;; action-name carousel.return
         (style (class (@ (name "suggested-action")))
                (class (@ (name "pill"))))))))

(define %carousel
  `(object (@ (class "AdwCarousel")
              (id "carousel"))
     (property (@ (name "vexpand")) True)
     (property (@ (name "hexpand")) True)
     ;; bind property allow-scroll-wheel
     ;;   source scroll-wheel // active // sync-create|bidirectional
     ;; bind property allow-long-swipes
     ;;   source long-swipes // active // sync-create|bidirectional
     (child ,%page-0)
     (child ,%page-1)
     (child ,%page-2)))

(define %indicators-stack
  `(object (@ (class "GtkStack")
              (id "indicators-stack"))
     (property (@ (name "vhomogeneous")) False)
     (property (@ (name "margin-top")) 6)
     (property (@ (name "margin-bottom")) 6)
     (property (@ (name "margin-start")) 6)
     (property (@ (name "margin-end")) 6)
     (child
         (object (@ (class "GtkStackPage"))
           (property (@ (name "name")) dots)
           (property (@ (name "child"))
             (object (@ (class "AdwCarouselIndicatorDots")
                        (id "indicators-dots"))
               (property (@ (name "carousel")) carousel)
               ;; bind property orientation
               ;;   source carousel // orientation // sync-create|bidirectional
               ))))
     (child
         (object (@ (class "GtkStackPage"))
           (property (@ (name "name")) lines)
           (property (@ (name "child"))
             (object (@ (class "AdwCarouselIndicatorLines")
                        (id "indicators-lines"))
               (property (@ (name "carousel")) carousel)
               ;; bind property orientation
               ;;   source carousel // orientation // sync-create|bidirectional
               ))))))

(define %carousel-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageCarousel")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "GtkBox")
                       (id "box"))
              (property (@ (name "orientation")) vertical)
              (child ,%empty-box)
              (child ,%carousel)
              (child ,%indicators-stack)
              )))))
    (object  (@ (class "GtkSizeGroup"))
      (property (@ (name "mode")) both)
      (widgets
       (widget (@ (name "empty-box")))
       (widget (@ (name "indicators-stack")))))))


(define (make-ui)
  (sxml->ui %carousel-page))
