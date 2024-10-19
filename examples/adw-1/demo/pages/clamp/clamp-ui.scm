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


(define %maximum-size-row
  '(object (@ (class "AdwSpinRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Maximum Size")
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment")
                  (id "maximum-size-adjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 10000)
         (property (@ (name "value")) 400)
         (property (@ (name "page-increment")) 100)
         (property (@ (name "step-increment")) 10)))))

(define %tightening-threshold-row
  '(object (@ (class "AdwSpinRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Tightening Threshold")
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment")
                  (id "tightening-threshold-adjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 10000)
         (property (@ (name "value")) 300)
         (property (@ (name "page-increment")) 100)
         (property (@ (name "step-increment")) 10)))))

(define %unit-row
  '(object (@ (class "AdwComboRow")
              (id "unit-row"))
     (property (@ (name "title")
                  (translatable "yes")) Unit)
     (property (@ (name "model"))
       (object (@ (class "AdwEnumListModel"))
         (property (@ (name "enum-type")) AdwLengthUnit)))
     (property (@ (name "expression"))
       (lookup (@ (type "AdwEnumListItem")
                  (name "nick"))))
     (property (@ (name "selected")) 2)))

(define %clamp-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageClamp")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "icon-name")) widget-clamp-symbolic)
              (property (@ (name "title")
                           (translatable "yes")) Clamp)
              (property (@ (name "description")
                           (translatable "yes"))
                "This page is clamped to smoothly grow up to a maximum width.")
              (property (@ (name "child"))
                (object (@ (class "AdwClamp")
                           (id "clamp"))
                  #;(property (@ (name "maximum-size")
                  (bind-source "maximum-size-adjustment") ;
                  (bind-property "value") ;
                  (bind-flags "sync-create")))
                  ;; property maximum-size
                  ;;   bind - maximum-size-adjustment // value // sync-create
                  (property (@ (name "child"))
                    (object (@ (class "AdwPreferencesGroup"))
                      (child ,%maximum-size-row)
                      (child ,%tightening-threshold-row)
                      (child ,%unit-row))))))))))))


(define (make-ui)
  (sxml->ui %clamp-page))
