;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023 - 2024
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


(define %prefs-group-1-1
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "description")
                  (translatable "yes")) "Preferences are organized in pages, this example has the following pages:")
     (property (@ (name "title")
                  (translatable "yes")) Pages)
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) L_ayout)
           (property (@ (name "use-underline")) True)))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) S_earch)
           (property (@ (name "use-underline")) True)))))

(define %prefs-group-1-2
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "description")
                  (translatable "yes")) "Preferences are grouped together, a group can have a title and a description. Descriptions will be wrapped if they are too long. This page has the following groups:")
     (property (@ (name "title")
                  (translatable "yes")) Groups)
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "An Untitled Group")))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) Pages)))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) Groups)))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) Preferences)))))

(define %prefs-group-1-3
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Preferences)
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Preferences rows are appended to the list box")))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "ellipsize")) end)
           (property (@ (name "label")
                        (translatable "yes")) "Other widgets are appended after the list box")
           (property (@ (name "margin-top")) 12)
           (property (@ (name "margin-bottom")) 12)
           (property (@ (name "xalign")) 0)
           (style (class (@ (name "dim-label"))))))))

(define %prefs-group-1-4
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Toasts)
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Show a Toast")
           (child
               (object (@ (class "GtkButton")
                          (id "toast-bt"))
                 (property (@ (name "label")
                              (translatable "yes")) Show)
                 ;; (property (@ (name "action-name")) toast.show)
                 (property (@ (name "valign")) center)))))))

(define %prefs-group-1-5
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "description")
                  (translatable "yes")) "Preferences windows can have subpages")
     (property (@ (name "title")
                  (translatable "yes")) Subpages)
     (child
         (object (@ (class "AdwActionRow")
                    (id "go-to-subpage-1-ar"))
           (property (@ (name "title")
                        (translatable "yes")) "Go to a Subpage")
           (property (@ (name "activatable")) True)
           ;; signal - activated - subpage1-activated-cb - swapped
           (child
               (object (@ (class "GtkImage"))
                 (property (@ (name "icon-name")) go-next-symbolic)))))
     (child
         (object (@ (class "AdwActionRow")
                    (id "go-to-subpage-2-ar"))
           (property (@ (name "title")
                        (translatable "yes")) "Go to Another Subpage")
           (property (@ (name "activatable")) True)
           ;; signal - activated - subpage2-activated-cb - swapped
           (child
               (object (@ (class "GtkImage"))
                 (property (@ (name "icon-name")) go-next-symbolic)))))))

(define %prefs-group-2-1
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "description")
                  (translatable "yes")) "Preferences can be searched, do so using one of the following ways:")
     (property (@ (name "title")
                  (translatable "yes")) Searching)
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Activate the Search Button")))
     (child
         (object (@ (class "AdwPreferencesRow"))
           (property (@ (name "title")
                        (translatable "yes")) Ctrl + f)
           (child
               (object (@ (class "AdwShortcutLabel"))
                 (property (@ (name "accelerator")) "<ctrl>f")
                 (property (@ (name "margin-top")) 12)
                 (property (@ (name "margin-bottom")) 12)
                 (property (@ (name "margin-start")) 12)
                 (property (@ (name "margin-end")) 12)))))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Directly Type Your Search")))))

(define %subpage-1
  '(object (@ (class "AdwNavigationPage")
              (id "subpage-1"))
     (property (@ (name "title")) Subpage)
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "AdwStatusPage"))
             (property (@ (name "title")
                          (translatable "yes")) "This Is a Subpage")
             (property (@ (name "child"))
               (object (@ (class "GtkButton")
                          (id "subpage-1-bt"))
                 (property (@ (name "label")
                              (translatable "yes")) "Open Another Subpage")
                 (property (@ (name "can-shrink")) True)
                 (property (@ (name "halign")) center)
                 ;; signal - clicked - subpage2-activate-cb - swapped
                 (style
                   (class (@ (name "pill"))))))))))))

(define %subpage-2
  '(object (@ (class "AdwNavigationPage")
              (id "subpage-2"))
     (property (@ (name "title")) "Another Subpage")
     (property (@ (name "child"))
       (object (@ (class "AdwToolbarView"))
         (child (@ (type "top"))
           (object (@ (class "AdwHeaderBar"))))
         (property (@ (name "content"))
           (object (@ (class "AdwStatusPage"))
             (property (@ (name "title")
                          (translatable "yes")) "This Is Another Subpage")))))))

(define %sxml
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPreferencesDialog")
                 (parent "AdwPreferencesDialog"))
      (property (@ (name "content-height")) 1000)
      (property (@ (name "search-enabled")) True)
      (child
          (object (@ (class "AdwPreferencesPage"))
            (property (@ (name "description")
                         (translatable "yes")) "Preferences pages can have a description")
            (property (@ (name "icon-name")) preferences-window-layout-symbolic)
            (property (@ (name "title")) L_ayout)
            (property (@ (name "use-underline")) True)
            (child ,%prefs-group-1-1)
            (child ,%prefs-group-1-2)
            (child ,%prefs-group-1-3)
            (child ,%prefs-group-1-4)
            (child ,%prefs-group-1-5)))
      (child
          (object (@ (class "AdwPreferencesPage"))
            (property (@ (name "icon-name")) preferences-window-search-symbolic)
            (property (@ (name "title")) _Search)
            (property (@ (name "use-underline")) True)
            (child ,%prefs-group-2-1))))
    ,%subpage-1
    ,%subpage-2))


(define (make-ui)
  (sxml->ui %sxml))
