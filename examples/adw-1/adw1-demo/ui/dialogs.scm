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


(define %dialogs
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageDialogs")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwStatusPage"))
          (property (@ (name "icon-name")) widget-dialog-symbolic)
          (property (@ (name "title")
                       (translatable "yes")) Dialogs)
          (property (@ (name "description")
                       (translatable "yes")) "Adaptive dialog widgets.")
          (property (@ (name "child"))
            (object (@ (class "GtkButton")
                       (id dialogs-button))
              (property (@ (name "label")
                           (translatable "yes")) "Alert Dialog")
              (property (@ (name "halign")) center)
              (style (class (@ (name "pill")))))))))))


(define (make-ui)
  (sxml->ui %dialogs))
