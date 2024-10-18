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


(define %prefs-group-1
  '(object (@ (class "AdwPreferencesGroup"))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Rows Have a Title")
           (property (@ (name "subtitle")
                        (translatable "yes")) "They also have a subtitle")))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Rows Can Have Suffix Widgets")
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Action)
                 (property (@ (name "valign")) center)))))))

(define %prefs-group-2
  '(object (@ (class "AdwPreferencesGroup"))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Rows Can Have Prefix Widgets")
           (property (@ (name "activatable-widget")) radio-button-1)
           (child (@ (type "prefix"))
             (object (@ (class "GtkCheckButton")
                        (id "radio-button-1"))
               (property (@ (name "valign")) center)y
               (property (@ (name "active")) True)))))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Rows Can Have Prefix Widgets")
           (property (@ (name "activatable-widget")) radio-button-2)
           (child (@ (type "prefix"))
             (object (@ (class "GtkCheckButton")
                        (id "radio-button-2"))
               (property (@ (name "group")) radio-button-1)
               (property (@ (name "valign")) center)))))))

(define %prefs-group-3
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Entry Rows")
     (property (@ (name "separate-rows")) True)
     (child
         (object (@ (class "AdwEntryRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Entry Row")
           (property (@ (name "use-underline")) True)))))

(define %prefs-group-4
  '(object (@ (class "AdwPreferencesGroup"))
     (child
         (object (@ (class "AdwEntryRow")
                    (id "entry-row-1"))
           (property (@ (name "title")
                        (translatable "yes")) "Entry With Confirmation")
           (property (@ (name "show-apply-button")) True)
           #;( signal - apply - entry-apply-cb - swapped )))
     (child
         (object (@ (class "AdwEntryRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Entry With Suffix")
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "valign")) center)
                 (property (@ (name "icon-name")) edit-copy-symbolic)
                 (property (@ (name "tooltip-text")
                              (translatable "yes")) copy)
                 (style (class (@ (name "flat"))))))))
     (child
         (object (@ (class "AdwPasswordEntryRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Password Entry")))))

(define %prefs-group-5
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Spin Rows")
     (child
         (object (@ (class "AdwSpinRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Spin Row")
           (property (@ (name "adjustment"))
             (object (@ (class "GtkAdjustment"))
               (property (@ (name "lower")) 0)
               (property (@ (name "upper")) 100)
               (property (@ (name "value")) 50)
               (property (@ (name "page-increment")) 10)
               (property (@ (name "step-increment")) 1)))))))

(define %prefs-group-6
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Switch Rows")
     (child
         (object (@ (class "AdwSwitchRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Switch Row")))))

(define %prefs-group-7
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Combo Rows")
     (child
         (object (@ (class "AdwComboRow")
                    (id "combo-row"))
           (property (@ (name "title")
                        (translatable "yes")) "Combo Row")
           (property (@ (name "model"))
             (object (@ (class "GtkStringList"))
               (items
                (item Foo)
                (item Bar)
                (item Baz))))))
     (child
         (object (@ (class "AdwComboRow")
                    (id "enum-combo-row"))
           (property (@ (name "title")
                        (translatable "yes")) "Enumaration Combo Row")
           (property (@ (name "subtitle")
                        (translatable "yes"))
             "This combo row was created from an enumaration")
           (property (@ (name "enable-search")) True)
           (property (@ (name "model"))
             (object (@ (class "AdwEnumListModel"))
               (property (@ (name "enum-type")) GtkLicense)))
           (property (@ (name "expression"))
             (lookup (@ (type "AdwEnumListItem")
                        (name "nick"))))))))

(define %prefs-group-8
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Expander Rows")
     (child
         (object (@ (class "AdwExpanderRow")
                    (id "expander-row"))
           (property (@ (name "title")
                        (translatable "yes")) "Expander Row")
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "A Nested Row")))
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "Another Nested Row")))))
     (child
         (object (@ (class "AdwExpanderRow")
                    (id "action-expander-row"))
           (property (@ (name "title")
                        (translatable "yes")) "Expander Row With an Action")
           (child (@ (type "suffix"))
               (object (@ (class "GtkButton"))
                 (property (@ (name "valign")) center)
                 (property (@ (name "icon-name")) edit-copy-symbolic)
                 (property (@ (name "tooltip-text")
                              (translatable "yes")) copy)
                 (style (class (@ (name "flat"))))))
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "A Nested Row")))
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "Another Nested Row")))))
     (child
         (object (@ (class "AdwExpanderRow")
                    (id "enable-expander-row"))
           (property (@ (name "title")
                        (translatable "yes")) "Toggleable Expander Row")
           (property (@ (name "show-enable-switch")) True)
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "A Nested Row")))
           (child
               (object (@ (class "AdwActionRow"))
                 (property (@ (name "title")
                              (translatable "yes")) "Another Nested Row")))))))

(define %prefs-group-9
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Property rows")
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Property Row")
           (property (@ (name "subtitle")
                        (translatable "yes")) "Value")
           (property (@ (name "subtitle-selectable")) True)
           (style (class (@ (name "property"))))))))

(define %prefs-group-10
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Group With Suffix")
     (property (@ (name "header-suffix"))
       (object (@ (class "GtkButton"))
         (property (@ (name "child"))
           (object (@ (class "AdwButtonContent"))
             (property (@ (name "icon-name")) list-add-symbolic)
             (property (@ (name "label")
                          (translatable "yes")) Suffix)))
         (style (class (@ (name "flat"))))))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes"))
             "Groups Can Have a Header Suffix")))))

(define %prefs-group-11
  '(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Button Rows")
     (property (@ (name "separate-rows")) True)
     (child
         (object (@ (class "AdwButtonRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Add Input Source")
           (property (@ (name "start-icon-name")) list-add-symbolic)))
     (child
         (object (@ (class "AdwButtonRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Add Calendar")
           (property (@ (name "start-icon-name")) go-next-symbolic)))
     (child
         (object (@ (class "AdwButtonRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Delete Event")
           (style (class (@ (name "destructive-action"))))))
     (child
         (object (@ (class "AdwButtonRow"))
           (property (@ (name "title")
                        (translatable "yes")) Search)
           (style (class (@ (name "suggested-action"))))))))


(define %lists
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageLists")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwStatusPage"))
          (property (@ (name "icon-name")) widget-list-symbolic)
          (property (@ (name "title")
                       (translatable "yes")) Lists)
          (property (@ (name "description")
                       (translatable "yes"))
            "Rows and helpers for GtkListBox")
          (property (@ (name "child"))
            (object (@ (class "AdwClamp")
                       (id "lists"))
              (property (@ (name "maximum-size")) 400)
              (property (@ (name "tightening-threshold")) 300)
              (property (@ (name "child"))
                (object (@ (class "GtkBox"))
                  (property (@ (name "orientation")) vertical)
                  (property (@ (name "spacing")) 12)
                  (child ,%prefs-group-1)
                  (child ,%prefs-group-2)
                  (child ,%prefs-group-3)
                  (child ,%prefs-group-4)
                  (child ,%prefs-group-5)
                  (child ,%prefs-group-6)
                  (child ,%prefs-group-7)
                  (child ,%prefs-group-8)
                  (child ,%prefs-group-9)
                  (child ,%prefs-group-10)
                  (child ,%prefs-group-11))))))))))


(define (make-ui)
  (sxml->ui %lists))
