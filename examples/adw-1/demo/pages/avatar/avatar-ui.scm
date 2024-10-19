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


(define %text
  '(object (@ (class "AdwEntryRow")
              (id "text"))
     (property (@ (name "title")
                  (translatable "yes")) Text)
     (property (@ (name "input-purpose")) name)
     (property (@ (name "input-hints")) "no-spellcheck | uppercase-words")))

(define %show-initials
  '(object (@ (class "AdwSwitchRow")
              (id "show-initials"))
     (property (@ (name "title")
                  (translatable "yes")) "Show Initials")
     (property (@ (name "active")) True)))

(define %file-action-row
  '(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) File)
     (child
         (object (@ (class "GtkButton")
                    (id "file-bt"))
           (property (@ (name "valign")) center)
           #;(property (@ (name "action-name")) avatar.open)
           (child
               (object (@ (class "GtkBox"))
                 (property (@ (name "spacing")) 6)
                 (child
                     (object (@ (class "GtkImage"))
                       (property (@ (name "icon-name")) document-open-symbolic)))
                 (child
                     (object (@ (class "GtkLabel")
                                (id "file-chooser-label"))
                       (property (@ (name "ellipsize")) middle)))))))
     (child
         (object (@ (class "GtkButton")
                    (id "trash-bt"))
           (property (@ (name "valign")) center)
           (property (@ (name "icon-name")) user-trash-symbolic)
           #;(property (@ (name "action-name")) avatar.remove)
           (style (class (@ (name "flat"))))))))

(define %spin-row
  '(object (@ (class "AdwSpinRow")
              (id "size"))
     (property (@ (name "title")
                  (translatable "yes")) Size)
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment")
                  (id "maximum-size-adjustment"))
         (property (@ (name "lower")) 24)
         (property (@ (name "upper")) 320)
         (property (@ (name "value")) 128)
         (property (@ (name "page-increment")) 8)
         (property (@ (name "step-increment")) 8)))))

(define %export-action-row
  '(object (@ (class "AdwActionRow"))
     (property (@ (name "title")
                  (translatable "yes")) "Export to File")
     (child
         (object (@ (class "GtkButton")
                    (id "export-bt"))
           (property (@ (name "valign")) center)
           (property (@ (name "icon-name")) avatar-save-symbolic)
           #;(property (@ (name "action-name")) avatar.save)
           (style (class (@ (name "flat"))))))))

(define %clamp
  `(object (@ (class "AdwClamp"))
     (property (@ (name "maximum-size")) 400)
     (property (@ (name "tightening-threshold")) 300)
     (property (@ (name "child"))
       (object (@ (class "GtkBox"))
         (property (@ (name "valign")) center)
         (property (@ (name "orientation")) vertical)
         (property (@ (name "spacing")) 12)
         (child
             (object (@ (class "AdwPreferencesGroup"))
               (child ,%text)
               (child ,%show-initials)
               (child ,%file-action-row)
               (child ,%spin-row)
               (child ,%export-action-row)))
         (child
             (object (@ (class "GtkListBox")
                        (id "contacts"))
               (property (@ (name "selection-mode")) none)
               (style (class (@ (name "boxed-list"))))))))))

(define %avatar-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageAvatar")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "GtkScrolledWindow"))
              (property (@ (name "hscrollbar-policy")) never)
              (property (@ (name "child"))
                (object (@ (class "GtkBox"))
                  (property (@ (name "orientation")) vertical)
                  (property (@ (name "valign")) start)
                  (style (class (@ (name "avatar-page"))))
                  (child
                      (object (@ (class "GtkBox"))
                        (property (@ (name "orientation")) vertical)
                        (child
                            (object (@ (class "AdwAvatar")
                                       (id "avatar"))
                              (property (@ (name "valign")) center)
                              ;; bind property size
                              ;;   source size // value // sync-create
                              ;; bind property show-initials
                              ;;   source show-initials // active // sync-create
                              ;; bind property text
                              ;;   source text // text // sync-create
                              (property (@ (name "margin-bottom")) 36)))
                        (child
                            (object (@ (class "GtkLabel"))
                              (property (@ (name "label")
                                           (translatable "yes")) Avatar)
                              (property (@ (name "wrap")) True)
                              (property (@ (name "wrap-mode")) word-char)
                              (property (@ (name "justify")) center)
                              (style (class (@ (name "title")))
                                     (class (@ (name "title-1"))))))
                        (child
                            (object (@ (class "GtkLabel"))
                              (property (@ (name "label")
                                           (translatable "yes"))
                                "A user avatar with generated fallback.")
                              (property (@ (name "wrap")) True)
                              (property (@ (name "justify")) center)
                              (property (@ (name "use-markup")) True)
                              (style (class (@ (name "body")))
                                     (class (@ (name "description"))))))
                        (child ,%clamp)
                        )))))))))))


(define (make-ui)
  (sxml->ui %avatar-page))
