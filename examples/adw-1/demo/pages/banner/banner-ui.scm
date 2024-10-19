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


(define %banner-pg-child-1
  '(object (@ (class "AdwSwitchRow")
              (id "show-banner-switch"))
     (property (@ (name "title")
                  (translatable "yes")) "Show Banner")
     (property (@ (name "active")) True)))

(define %banner-pg-child-2
  '(object (@ (class "AdwEntryRow")
              (id "title-row"))
     (property (@ (name "title")
                  (translatable "yes")) Title)
     (property (@ (name "use-underline")) True)
     (property (@ (name "text")) "Metered connection – updates paused")
     (property (@ (name "input-hints")) "spellcheck | word-completion | uppercase-sentences")))

(define %banner-pg-child-3
  '(object (@ (class "AdwEntryRow")
              (id "button-label-row"))
     (property (@ (name "title")
                  (translatable "yes")) Button)
     (property (@ (name "use-underline")) True)
     (property (@ (name "text")) "_Network Settings")
     (property (@ (name "input-hints")) "spellcheck | word-completion | uppercase-sentences")
     (property (@ (name "editable")
                  (bind-source "label-switch")
                  (bind-property "active")
                  (bind-flags "sync-create")))
     ;; signal - notify::text - update-button-cb - swapped
     ;; signal - notify::editable - update-button-cb - swapped
     (child
         (object (@ (class "GtkSwitch")
                    (id "label-switch"))
           (property (@ (name "valign")) center)
           (property (@ (name "active")) True)))))


(define %banner-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageBanner")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "GtkCenterBox"))
              (property (@ (name "vexpand")) True)
              (property (@ (name "orientation")) vertical)
              (child (@ (type "start"))
                (object (@ (class "AdwBanner")
                           (id "banner"))
                  (property (@ (name "revealed")
                               (bind-source "show-banner-switch")
                               (bind-property "active")
                               (bind-flags "sync-create|bidirectional")))
                  (property (@ (name "title")
                               (bind-source "title-row")
                               (bind-property "text")
                               (bind-flags "sync-create")))
                  (property (@ (name "action-name")) banner.activate)))
              (child (@ (type "center"))
                (object (@ (class "AdwStatusPage"))
                  (property (@ (name "title")
                               (translatable "yes")) Banner)
                  (property (@ (name "description")
                               (translatable "yes")) "A bar with contextual information.")
                  (property (@ (name "icon-name")) widget-banner-symbolic)
                  (property (@ (name "child"))
                    (object (@ (class "AdwClamp"))
                      (property (@ (name "maximum-size")) 400)
                      (property (@ (name "tightening-threshold")) 300)
                      (child
                          (object (@ (class "AdwPreferencesGroup"))
                            (child ,%banner-pg-child-1)
                            (child ,%banner-pg-child-2)
                            (child ,%banner-pg-child-3))))))))))))))


(define (make-ui)
  (sxml->ui %banner-page))
