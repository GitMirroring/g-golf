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


(define %bottom-sheets
  `(interface
     (requires (@ (version "4.0") (lib "gtk")))
     (requires (@ (version "1.0") (lib "libadwaita")))
     (template (@ (class "AdwDemoPageBottomSheets")
                  (parent "AdwBin"))
       (property (@ (name "child"))
         (object (@ (class "AdwBottomSheet")
                    (id "sheet"))
           (property (@ (name "content"))
             (object (@ (class "AdwToolbarView"))
               (child (@ (type "top"))
                 (object (@ (class "AdwHeaderBar")
                            (id "header-bar"))
                   (property (@ (name "show-title")) False)))
               (property (@ (name "content"))
                 (object (@ (class "AdwStatusPage"))
                   (property (@ (name "icon-name")) widget-bottom-sheet-symbolic)
                   (property (@ (name "title")
                                (translatable "yes")) "Bottom Sheet")
                   (property (@ (name "description")
                                (translatable "yes"))
                     "A bottom sheet with an optional bottom bar")
                   (property (@ (name "margin-bottom")
                                (bind-source "sheet")
                                (bind-property "bottom-bar-height")
                                (bind-flags "sync-create")))))))
           (property (@ (name "sheet"))
             (object (@ (class "AdwToolbarView"))
               (child (@ (type "top"))
                 (object (@ (class "AdwHeaderBar"))))
               (property (@ (name "content"))
                 (object (@ (class "AdwStatusPage"))
                   (property (@ (name "icon-name")) go-down-symbolic)))))
           (property (@ (name "bottom-bar"))
             (object (@ (class "GtkCenterBox"))
               (style (class (@ (name "toolbar"))))
               (property (@ (name "height-request")) 46)
               (property (@ (name "center-widget"))
                 (object (@ (class "GtkLabel"))
                   (property (@ (name "label")) "Pull Up Here")
                   (property (@ (name "ellipsize")) end))))))))))

(define (make-ui)
  (sxml->ui %bottom-sheets))
