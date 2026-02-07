;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2026
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


(define %general
  '(object (@ (class "AdwShortcutsSection"))
     (property (@ (name "title")
                  (translatable "yes")) General)
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Open Menu")
           (property (@ (name "accelerator")) F10)))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) Preferences)
           (property (@ (name "accelerator")) "<Ctrl>comma")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Keyboard Shortcuts")
           (property (@ (name "accelerator")) "<Ctrl>question")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Close Current Window")
           (property (@ (name "accelerator")) "<Ctrl>W")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) Quit)
           (property (@ (name "accelerator")) "<Ctrl>Q")))))

(define %tab-view-1
  '(object (@ (class "AdwShortcutsSection"))
     (property (@ (name "title")
                  (translatable "yes")) "Tab View")
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "New Tab")
           (property (@ (name "accelerator")) "<Ctrl>T")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "New Window")
           (property (@ (name "accelerator")) "<Ctrl>N")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Close Tab")
           (property (@ (name "accelerator")) "<Ctrl>W")))))

(define %tab-view-2
  '(object (@ (class "AdwShortcutsSection"))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Previous Tab")
           (property (@ (name "accelerator")) "<Shift><Ctrl>Tab <Ctrl>Page_Up")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Next Tab")
           (property (@ (name "accelerator")) "<Ctrl>Tab <Ctrl>Page_Down")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "First Tab")
           (property (@ (name "accelerator")) "<Ctrl>Home")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Last Tab")
           (property (@ (name "accelerator")) "<Ctrl>End")))))

(define %tab-view-3
  '(object (@ (class "AdwShortcutsSection"))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Move Tab Left")
           (property (@ (name "accelerator")) "<Shift><Ctrl>Page_Up")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Move Tab Right")
           (property (@ (name "accelerator")) "<Shift><Ctrl>Page_Down")))))

(define %tab-view-4
  '(object (@ (class "AdwShortcutsSection"))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Switch to Tab 1-9")
           (property (@ (name "accelerator")) "<Alt>1...9")))
     (child
         (object (@ (class "AdwShortcutsItem"))
           (property (@ (name "title")
                        (translatable "yes")) "Switch to Tab 10")
           (property (@ (name "accelerator")) "<Alt>0")))))


(define %sxml
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (object (@ (class "AdwShortcutsDialog")
               (id "shortcuts-dialog"))
      (child ,%general)
      (child ,%tab-view-1)
      (child ,%tab-view-2)
      (child ,%tab-view-3)
      (child ,%tab-view-4))))


(define (make-ui)
  (sxml->ui %sxml))
