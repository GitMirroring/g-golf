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


(define %wrap-box-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageWrapBox")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "AdwStatusPage"))
              (property (@ (name "title")
                           (translatable "yes")) "Wrap Box")
              (property (@ (name "description")
                           (translatable "yes")) "A box-like widget that can wrap into multiple lines.")
              (property (@ (name "icon-name")) widget-view-switcher-symbolic)
              (property (@ (name "child"))
                (object (@ (class "AdwClamp"))
                  (property (@ (name "child"))
                    (object (@ (class "AdwWrapBox")
                               (id "wrap-box"))
                      (property (@ (name "line-spacing")) 6)
                      (property (@ (name "child-spacing")) 6)
                      (child
                          (object (@ (class "GtkButton")
                                     (id "add-bt"))
                            (property (@ (name "icon-name")) list-add-symbolic)
                            (property (@ (name "action-name")) wb.add-tag)
                            (style (class (@ (name "flat")))
                                   (class (@ (name "circular")))))))))))))))))


(define (make-ui)
  (sxml->ui %wrap-box-page))
