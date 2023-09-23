;; -*- mode: sxml-ui; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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


(define %demo-menu
  '(menu (@ (id "demo-menu"))
     (section
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 1")
         (attribute (@ (name "action")) style.dummy))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 2")
         (attribute (@ (name "action")) style.dummy))
       (item
         (attribute (@ (name "label")
                       (translatable "yes")) "Item 3")
         (attribute (@ (name "action")) style.dummy)))))


(define %status-pages-sidebar
  '(property (@ (name "sidebar"))
     (object (@ (class "AdwStatusPage"))
       (property (@ (name "icon-name")) org.gnome.Adwaita1.Demo-symbolic)
       (property (@ (name "title")
                    (translatable "yes")) Compact)
       (property (@ (name "description")
                    (translatable "yes")) "This status page has the \"compact\" style class.")
       (property (@ (name "tooltip-text")) compact)
       (style (class (@ (name "compact"))))
       (property (@ (name "child"))
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Buttom)
           (property (@ (name "halign")) center)
           (style (class (@ (name "pill")))))))))

(define %status-pages-content
  '(property (@ (name "content"))
     (object (@ (class "AdwStatusPage"))
       (property (@ (name "hexpand")) True)
       (property (@ (name "icon-name")) org.gnome.Adwaita1.Demo-symbolic)
       (property (@ (name "title")
                    (translatable "yes")) Regular)
       (property (@ (name "description")
                    (translatable "yes")) "This is a regular status pag.")
       (property (@ (name "child"))
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Buttom)
           (property (@ (name "halign")) center)
           (style (class (@ (name "pill")))))))))

(define %status-pages
  `(object (@ (class "AdwWindow")
              (id "status-pages-window"))
     (property (@ (name "modal")) True)
     (property (@ (name "transient-for")) AdwStyleClassesDemoWindow)
     (property (@ (name "title")
                  (translatable "yes")) "Status Pages")
     (property (@ (name "hide-on-close")) True)
     (property (@ (name "default-width")) 640)
     (property (@ (name "default-height")) 480)
     (property (@ (name "width-request")) 360)
     (property (@ (name "height-request")) 200)
     (child
         (object (@ (class "GtkShortcutController"))
           (property (@ (name "scope")) managed)
           (child
               (object (@ (class "GtkShortcut"))
                 (property (@ (name "trigger")) Escape)
                 (property (@ (name "action")) "action(window.close)")))))
     (property (@ (name "content"))
       (object (@ (class "AdwToolbarView"))
         (property (@ (name "top-bar-style")) raised)
         (child (@ (type "top"))
           (object (@ (class "GtkHeaderBar"))
             (child
                 (object (@ (class "GtkToggleButton")
                            (id "compact-toggle-button"))
                   (property (@ (name "icon-name")) view-sidebar-start)
                   (property (@ (name "active")
                                (bind-source "compact-split-view")
                                (bind-property "show-sidebar")
                                (bind-flags "sync-create|bidirectional")))))))
         (property (@ (name "content"))
           (object (@ (class "AdwOverlaySplitView")
                      (id "compact-split-view"))
             ,%status-pages-sidebar
             ,%status-pages-content))))
     (child
         (object (@ (class "AdwBreakpoint"))
           (condition "max-width: 450sp")
           (setter (@ (object "compact-split-view")
                      (property "collapsed")) True)
           (setter (@ (object "compact-toggle-button")
                      (property "visible")) True)))))

(define %sidebar-sidebar
  '(property (@ (name "sidebar"))
     (object (@ (class "AdwNavigationPage"))
       ;; libadwaita-1-0:amd64 1.4~rc-1 complains if none, despite
       ;; its AdwHeaderBar show-title property set to false ...
       (property (@ (name "title")) "Bluefox") ;; fake title
       (property (@ (name "child"))
         (object (@ (class "AdwToolbarView"))
           (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))
               (property (@ (name "show-title")) False)))
           (child
               (object (@ (class "GtkScrolledWindow"))
                 (property (@ (name "hscrollbar-policy")) never)
                 (property (@ (name "child"))
                   (object (@ (class "GtkListBox")
                              (id "sidebar-list"))
                     (property (@ (name "tooltip-text")) navigation-sidebar)
                     (property (@ (name "selection-mode")) browse)
                     ;; signal - row-activated - sidebar-forward-cb - swapped
                     (style (class (@ (name "navigation-sidebar"))))
                     (child
                         (object (@ (class "GtkLabel"))
                           (property (@ (name "label")
                                        (translatable "yes")) "Item 1")
                           (property (@ (name "ellipsize")) end)
                           (property (@ (name "xalign")) 0)))
                     (child
                         (object (@ (class "GtkLabel"))
                           (property (@ (name "label")
                                        (translatable "yes")) "Item 2")
                           (property (@ (name "ellipsize")) end)
                           (property (@ (name "xalign")) 0)))
                     (child
                         (object (@ (class "GtkLabel"))
                           (property (@ (name "label")
                                        (translatable "yes")) "Item 3")
                           (property (@ (name "ellipsize")) end)
                           (property (@ (name "xalign")) 0)))
                     (child
                         (object (@ (class "GtkLabel"))
                           (property (@ (name "label")
                                        (translatable "yes")) "Item 4")
                           (property (@ (name "ellipsize")) end)
                           (property (@ (name "xalign")) 0)))
                     (child
                         (object (@ (class "GtkLabel"))
                           (property (@ (name "label")
                                        (translatable "yes")) "Item 5")
                           (property (@ (name "ellipsize")) end)
                           (property (@ (name "xalign")) 0))))))))))))

(define %sidebar-content
  '(property (@ (name "content"))
     (object (@ (class "AdwNavigationPage"))
       (property (@ (name "title")
                    (translatable "yes")) Sidebar)
       (property (@ (name "tag")) content)
       (property (@ (name "child"))
         (object (@ (class "AdwToolbarView"))
           (child (@ (type "top"))
             (object (@ (class "AdwHeaderBar"))))
           (child
               (object (@ (class "AdwStatusPage"))
                 (property (@ (name "title")
                              (translatable "yes")) Sidebar)
                 (property (@ (name "description")
                              (translatable "yes")) "\"navigation-sidebar\" style class on GtkListBox or GtkListView."))))))))

(define %sidebar
  `(object (@ (class "AdwWindow")
              (id "sidebar-window"))
     (property (@ (name "modal")) True)
     (property (@ (name "transient-for")) AdwStyleClassesDemoWindow)
     (property (@ (name "title")
                  (translatable "yes")) Sidebar)
     (property (@ (name "hide-on-close")) True)
     (property (@ (name "default-width")) 720)
     (property (@ (name "default-height")) 480)
     (property (@ (name "width-request")) 360)
     (property (@ (name "height-request")) 240)
     (child
         (object (@ (class "GtkShortcutController"))
           (property (@ (name "scope")) managed)
           (child
               (object (@ (class "GtkShortcut"))
                 (property (@ (name "trigger")) Escape)
                 (property (@ (name "action")) "action(window.close)")))))
     (property (@ (name "content"))
       (object (@ (class "AdwNavigationSplitView")
                  (id "sidebar-split-view"))
         (property (@ (name "min-sidebar-width")) 140)
         (property (@ (name "max-sidebar-width")) 240)
         ,%sidebar-sidebar
         ,%sidebar-content))
     (child
         (object (@ (class "AdwBreakpoint"))
           (condition "max-width: 450sp")
           (setter (@ (object "sidebar-split-view")
                      (property "collapsed")) True)
           (setter (@ (object "sidebar-list")
                      (property "selection-mode")) none)))))


(define %progress-bar
  '(object (@ (class "GtkProgressBar")
              (id "progress-bar"))
     (property (@ (name "valign")) start)
     (property (@ (name "fraction")) 0.5)
     (property (@ (name "tooltip-text")) osd)
     (property (@ (name "visible")) False)
     #;(binding (@ (name "visible"))
       (lookup (@ (name "progress")) "AdwStyleClassesDemoWindow"))
     (style (class (@ (name "osd"))))))


(define %button-box-1
  '(object (@ (class "GtkBox")
              (id "button-box-1"))
     (property (@ (name "spacing")) 6)
     (property (@ (name "homogeneous")) True)
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "homogeneous")) True)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Regular)
                 (property (@ (name "can-shrink")) True)))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Flat)
                 (property (@ (name "tooltip-text")) flat)
                 (property (@ (name "can-shrink")) True)
                 (style (class (@ (name "flat"))))))))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "homogeneous")) True)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Suggested)
                 (property (@ (name "tooltip-text")) suggested-action)
                 (property (@ (name "can-shrink")) True)
                 (style (class (@ (name "suggested-action"))))))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Destructive)
                 (property (@ (name "tooltip-text")) destructive-action)
                 (property (@ (name "can-shrink")) True)
                 (style (class (@ (name "destructive-action"))))))))))

(define %button-box-2
  '(object (@ (class "GtkBox")
              (id "button-box-2"))
     (property (@ (name "spacing")) 6)
     (property (@ (name "homogeneous")) True)
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "homogeneous")) True)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Custom)
                 (property (@ (name "name")) custom-button-1)
                 (property (@ (name "can-shrink")) True)))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Custom)
                 (property (@ (name "name")) custom-button-2)
                 (property (@ (name "can-shrink")) True)))))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "homogeneous")) True)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Custom)
                 (property (@ (name "name")) custom-button-3)
                 (property (@ (name "tooltip-text")) opaque)
                 (property (@ (name "can-shrink")) True)
                 (style (class (@ (name "opaque"))))))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) Custom)
                 (property (@ (name "name")) custom-button-4)
                 (property (@ (name "tooltip-text")) opaque)
                 (property (@ (name "can-shrink")) True)
                 (style (class (@ (name "opaque"))))))))))

(define %button-box-3
  '(object (@ (class "GtkBox")
              (id "button-box-3"))
     (property (@ (name "spacing")) 6)
     (property (@ (name "margin-top")) 12)
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "halign")) center)
           (property (@ (name "valign")) center)
           (property (@ (name "hexpand")) True)
           (property (@ (name "tooltip-text")) circular)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) "Pill Button")
                 (property (@ (name "halign")) center)
                 (property (@ (name "valign")) center)
                 (property (@ (name "tooltip-text")) pill)
                 (property (@ (name "icon-name")) list-add-symbolic)
                 (style (class (@ (name "circular"))))))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "label")
                              (translatable "yes")) A)
                 (property (@ (name "tooltip-text")) circular)
                 (style (class (@ (name "circular"))))))))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) "Pill Button")
           (property (@ (name "halign")) center)
           (property (@ (name "valign")) center)
           (property (@ (name "hexpand")) True)
           (property (@ (name "tooltip-text")) pill)
           (property (@ (name "can-shrink")) True)
           (style (class (@ (name "pill"))))))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "halign")) center)
           (property (@ (name "valign")) center)
           (property (@ (name "hexpand")) True)
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "icon-name")) go-previous-symbolic)
                 (property (@ (name "tooltip-text")) osd)
                 (style (class (@ (name "osd"))))))
           (child
               (object (@ (class "GtkButton"))
                 (property (@ (name "icon-name")) go-next-symbolic)
                 (property (@ (name "tooltip-text")) osd)
                 (style (class (@ (name "osd"))))))))))

(define %buttons
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Buttoms)
     (property (@ (name "description")
                  (translatable "yes")) "The \"flat\", \"suggested-action\" and \"destructive\" style classes action can be used together with \"pill\" or \"circular\".

The \"opaque\" style class allows to create buttons with custom colors that look similar to \"suggested-action\".")
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "orientation")) vertical)
           (child ,%button-box-1)
           (child ,%button-box-2)
           (child ,%button-box-3)))))


(define %entry-box-1
  '(object (@ (class "GtkBox")
              (id "entry-box-1"))
     (property (@ (name "spacing")) 6)
     (property (@ (name "homogeneous")) True)
     (property (@ (name "hexpand")) True)
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Regular)
           (property (@ (name "text")
                        (translatable "yes")) Regular)
           (property (@ (name "secondary-icon-name")) edit-copy-symbolic)))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Success)
           (property (@ (name "text")
                        (translatable "yes")) Success)
           (property (@ (name "tooltip-text")) success)
           (property (@ (name "secondary-icon-name")) edit-copy-symbolic)
           (style (class (@ (name "success"))))))))

(define %entry-box-2
  '(object (@ (class "GtkBox")
              (id "entry-box-2"))
     (property (@ (name "spacing")) 6)
     (property (@ (name "homogeneous")) True)
     (property (@ (name "hexpand")) True)
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Warning)
           (property (@ (name "text")
                        (translatable "yes")) Warning)
           (property (@ (name "tooltip-text")) warning)
           (property (@ (name "secondary-icon-name")) edit-copy-symbolic)
           (style (class (@ (name "warning"))))))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Error)
           (property (@ (name "text")
                        (translatable "yes")) Error)
           (property (@ (name "tooltip-text")) error)
           (property (@ (name "secondary-icon-name")) edit-copy-symbolic)
           (style (class (@ (name "error"))))))))

(define %entries
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Entries)
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "orientation")) vertical)
           (child ,%entry-box-1)
           (child ,%entry-box-2)))))


(define %linked-controls-box-1
  '(object (@ (class "GtkBox"))
     (property (@ (name "tooltip-text")) linked)
     (style (class (@ (name "linked"))))
     (child
         (object (@ (class "GtkToggleButton")
                    (id "toggle"))
           (property (@ (name "icon-name")) view-grid-symbolic)
           (property (@ (name "active")) True)))
     (child
         (object (@ (class "GtkToggleButton"))
           (property (@ (name "icon-name")) view-list-symbolic)
           (property (@ (name "group")) toggle)))))

(define %linked-controls-box-2
  '(object (@ (class "GtkBox"))
     (property (@ (name "tooltip-text")) linked)
     (style (class (@ (name "linked"))))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Entry)
           (property (@ (name "hexpand")) True)))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Entry)
           (property (@ (name "hexpand")) True)))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "label")
                        (translatable "yes")) Button)
           (property (@ (name "can-shrink")) True)))))

(define %linked-controls-box-3
  '(object (@ (class "GtkBox"))
     (property (@ (name "orientation")) vertical)
     (property (@ (name "tooltip-text")) linked)
     (style (class (@ (name "linked"))))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) edit-cut-symbolic)))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) edit-copy-symbolic)))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) edit-paste-symbolic)))))

(define %linked-controls-box-4
  '(object (@ (class "GtkBox"))
     (property (@ (name "orientation")) vertical)
     (property (@ (name "hexpand")) True)
     (property (@ (name "tooltip-text")) linked)
     (style (class (@ (name "linked"))))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Street)))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) City)))
     (child
         (object (@ (class "GtkEntry"))
           (property (@ (name "placeholder-text")
                        (translatable "yes")) Province)))))

(define %linked-controls
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Linked Controls")
     (property (@ (name "description")
                  (translatable "yes")) "The \"linked\" style on GtkBox and similar containers allows to visually join related button-like and entry-like widgets.")
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (child ,%linked-controls-box-1)
           (child ,%linked-controls-box-2)))
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "spacing")) 6)
           (property (@ (name "margin-top")) 6)
           (child ,%linked-controls-box-3)
           (child ,%linked-controls-box-4)))))


(define %labels-box-1
  '(object (@ (class "GtkBox"))
     (property (@ (name "orientation")) vertical)
     (property (@ (name "spacing")) 12)
     (property (@ (name "hexpand")) True)
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Title 1")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) title-1)
           (style (class (@ (name "title-1"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Title 2")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) title-2)
           (style (class (@ (name "title-2"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Title 3")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) title-3)
           (style (class (@ (name "title-3"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Title 4")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) title-4)
           (style (class (@ (name "title-4"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Monospace)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) monospace)
           (style (class (@ (name "monospace"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Numeric (1234567890)")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) numeric)
           (style (class (@ (name "numeric"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Accent)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) accent)
           (style (class (@ (name "accent"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Success)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) success)
           (style (class (@ (name "success"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Warning)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) warning)
           (style (class (@ (name "warning"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Error)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) error)
           (style (class (@ (name "error"))))))))

(define %labels-box-2
  '(object (@ (class "GtkBox"))
     (property (@ (name "orientation")) vertical)
     (property (@ (name "spacing")) 12)
     (property (@ (name "hexpand")) True)
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) Heading)
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) heading)
           (style (class (@ (name "heading"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "This is a paragraph of a body copy. You would use this style for most text in interfaces. It can also include <b>styling</b> or <a href=\"https://os.gnome.org/\"> links</a> .")
           (property (@ (name "use-markup")) True)
           (property (@ (name "xalign")) 0)
           (property (@ (name "wrap")) True)
           (property (@ (name "wrap-mode")) word-char)
           (property (@ (name "max-width-chars")) 25)
           (property (@ (name "tooltip-text")) body)
           (style (class (@ (name "body"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Caption Heading")
           (property (@ (name "xalign")) 0)
           (property (@ (name "ellipsize")) end)
           (property (@ (name "tooltip-text")) caption-heading)
           (style (class (@ (name "caption-heading"))))))
     (child
         (object (@ (class "GtkLabel"))
           (property (@ (name "label")
                        (translatable "yes")) "Caption body text, to be used for body copy on image captions and the like.")
           (property (@ (name "xalign")) 0)
           (property (@ (name "wrap")) True)
           (property (@ (name "wrap-mode")) word-char)
           (property (@ (name "max-width-chars")) 25)
           (property (@ (name "tooltip-text")) caption)
           (style (class (@ (name "caption"))))))))

(define %labels
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Labels)
     (child
         (object (@ (class "GtkBox")
                    (id "label-box"))
           (property (@ (name "spacing")) 18)
           (child ,%labels-box-1)
           (child ,%labels-box-2)))))


(define %cards-and-boxed-lists-box
  '(object (@ (class "GtkBox"))
     (property (@ (name "homogeneous")) True)
     (property (@ (name "height-request")) 100)
     (property (@ (name "spacing")) 12)
     (property (@ (name "margin-bottom")) 12)
     (child
         (object (@ (class "AdwBin"))
           (property (@ (name "tooltip-text")) card)
           (style (class (@ (name "card"))))
           (property (@ (name "child"))
             (object (@ (class "GtkLabel"))
               (property (@ (name "label")
                            (translatable "yes")) Card)
               (property (@ (name "wrap")) True)
               (property (@ (name "wrap-mode")) word-char)))))
     (child
         (object (@ (class "AdwBin"))
           (property (@ (name "tooltip-text")) "card, activatable")
           (property (@ (name "focusable")) True)
           (style (class (@ (name "card")))
             (class (@ (name "activatable"))))
           (property (@ (name "child"))
             (object (@ (class "GtkLabel"))
               (property (@ (name "label")
                            (translatable "yes")) "Card (activatable)")
               (property (@ (name "wrap")) True)
               (property (@ (name "wrap-mode")) word-char)))))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "tooltip-text")) card)
           (style (class (@ (name "card"))))
           (property (@ (name "child"))
             (object (@ (class "GtkLabel"))
               (property (@ (name "label")
                            (translatable "yes")) "Card (button)")
               (property (@ (name "wrap")) True)
               (property (@ (name "wrap-mode")) word-char)))))))

(define %cards-and-boxed-lists-listbox
  '(object (@ (class "GtkListBox"))
     (property (@ (name "selection-mode")) none)
     (property (@ (name "tooltip-text")) boxed-list)
     (style (class (@ (name "boxed-list"))))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) Row)))
     (child
         (object (@ (class "AdwActionRow"))
           (property (@ (name "title")
                        (translatable "yes")) "Row (activatable)")
           (property (@ (name "activatable")) True)))))

(define %cards-and-boxed-lists
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Cards and Boxed Lists")
     (property (@ (name "description")
                  (translatable "yes")) "The \"boxed-list\" style class can be used with GtkListBox to create boxed lists.

The \"card\" style class can be used to achieve the same style with GtkBox or similar containers, and with GtkButton. If used together with \"activatable\" style class, or on a GtkButton, the card will also have hover and press styles.")
     (child ,%cards-and-boxed-lists-box)
     (child ,%cards-and-boxed-lists-listbox)))


(define %app-icons-grid-column-1
  '((child
        (object (@ (class "GtkImage"))
          (property (@ (name "icon-name")) org.gnome.Boxes)
          (property (@ (name "pixel-size")) 128)
          (property (@ (name "valign")) end)
          (property (@ (name "tooltip-text")) icon-dropshadow)
          (style (class (@ (name "icon-dropshadow"))))
          (layout (property (@ (name "column")) 0)
                  (property (@ (name "row")) 0))))
    (child
        (object (@ (class "GtkLabel"))
          (property (@ (name "label")) 128)
          (property (@ (name "xalign")) 0.5)
          (layout (property (@ (name "column")) 0)
                  (property (@ (name "row")) 1))))))

(define %app-icons-grid-column-2
  '((child
        (object (@ (class "GtkImage"))
          (property (@ (name "icon-name")) org.gnome.Boxes)
          (property (@ (name "pixel-size")) 64)
          (property (@ (name "valign")) end)
          (property (@ (name "tooltip-text")) icon-dropshadow)
          (style (class (@ (name "icon-dropshadow"))))
          (layout (property (@ (name "column")) 1)
                  (property (@ (name "row")) 0))))
    (child
        (object (@ (class "GtkLabel"))
          (property (@ (name "label")) 64)
          (property (@ (name "xalign")) 0.5)
          (layout (property (@ (name "column")) 1)
                  (property (@ (name "row")) 1))))))

(define %app-icons-grid-column-3
  '((child
        (object (@ (class "GtkImage"))
          (property (@ (name "icon-name")) org.gnome.Boxes)
          (property (@ (name "pixel-size")) 32)
          (property (@ (name "valign")) end)
          (property (@ (name "tooltip-text")) icon-dropshadow)
          (style (class (@ (name "icon-dropshadow"))))
          (layout (property (@ (name "column")) 2)
                  (property (@ (name "row")) 0))))
    (child
        (object (@ (class "GtkLabel"))
          (property (@ (name "label")) 32)
          (property (@ (name "xalign")) 0.5)
          (layout (property (@ (name "column")) 2)
                  (property (@ (name "row")) 1))))))

(define %app-icons
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "App Icons")
     (property (@ (name "description")
                  (translatable "yes")) "The \"icon-dropshadow\" style class ensures legibility when displaying app icons. For 32x32 and smaller app icons, \"lowres-icon\" should be used instead.")
     (child
         (object (@ (class "GtkGrid"))
           (property (@ (name "row-spacing")) 6)
           (property (@ (name "column-spacing")) 12)
           ,@%app-icons-grid-column-1
           ,@%app-icons-grid-column-2
           ,@%app-icons-grid-column-3))))


(define %check-buttons-group-1
  '((child
        (object (@ (class "GtkCheckButton"))
          (property (@ (name "halign")) end)
          (property (@ (name "valign")) end)
          (property (@ (name "active")) True)
          (layout (property (@ (name "column")) 0)
                  (property (@ (name "row")) 0))))
    (child
        (object (@ (class "GtkCheckButton"))
          (property (@ (name "halign")) start)
          (property (@ (name "valign")) end)
          (layout (property (@ (name "column")) 1)
                  (property (@ (name "row")) 0))))
    (child
     (object (@ (class "GtkLabel"))
       (property (@ (name "label")
                    (translatable "yes")) Regular)
       (property (@ (name "xalign")) 0.5)
       (property (@ (name "margin-start")) 12)
       (property (@ (name "margin-end")) 12)
       (property (@ (name "wrap")) True)
       (property (@ (name "wrap-mode")) word-char)
       (layout (property (@ (name "column")) 0)
               (property (@ (name "row")) 1)
               (property (@ (name "column-span")) 2))))))

(define %check-buttons-group-2
  '((child
        (object (@ (class "GtkCheckButton"))
          (property (@ (name "halign")) end)
          (property (@ (name "valign")) end)
          (property (@ (name "active")) True)
          (property (@ (name "tooltip-text")) selection-mode)
          (style (class (@ (name "selection-mode"))))
          (layout (property (@ (name "column")) 2)
                  (property (@ (name "row")) 0))))
    (child
        (object (@ (class "GtkCheckButton"))
          (property (@ (name "halign")) start)
          (property (@ (name "valign")) end)
          (property (@ (name "tooltip-text")) selection-mode)
          (style (class (@ (name "selection-mode"))))
          (layout (property (@ (name "column")) 3)
                  (property (@ (name "row")) 0))))
    (child
     (object (@ (class "GtkLabel"))
       (property (@ (name "label")
                    (translatable "yes")) "Selection Mode")
       (property (@ (name "xalign")) 0.5)
       (property (@ (name "margin-start")) 12)
       (property (@ (name "margin-end")) 12)
       (property (@ (name "wrap")) True)
       (property (@ (name "wrap-mode")) word-char)
       (layout (property (@ (name "column")) 2)
               (property (@ (name "row")) 1)
               (property (@ (name "column-span")) 2))))))

(define %check-buttons
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) "Check Buttons")
     (property (@ (name "description")
                  (translatable "yes")) "The \"selection-mode\" style class makes can be used with GtkCheckButton to make them large and round.")
     (child
         (object (@ (class "GtkGrid"))
           (property (@ (name "row-spacing")) 6)
           (property (@ (name "column-spacing")) 12)
           (property (@ (name "halign")) start)
           ,@%check-buttons-group-1
           ,@%check-buttons-group-2))))


(define %toolbar-1
  '(object (@ (class "GtkFrame"))
     (property (@ (name "margin-bottom")) 12)
     (property (@ (name "child"))
       (object (@ (class "GtkBox"))
         (property (@ (name "tooltip-text")) toolbar)
         (style (class (@ (name "toolbar"))))
         (child
             (object (@ (class "GtkMenuButton"))
               (property (@ (name "label")
                            (translatable "yes")) Open)
               (property (@ (name "menu-model")) demo-menu)))
         (child
             (object (@ (class "GtkButton"))
               (property (@ (name "icon-name")) tab-new-symbolic)))
         (child
             (object (@ (class "GtkSeparator"))
               (property (@ (name "hexpand")) True)
               (style (class (@ (name "spacer"))))))
         (child
             (object (@ (class "GtkButton"))
               (property (@ (name "icon-name")) edit-undo-symbolic)))
         (child
             (object (@ (class "GtkButton"))
               (property (@ (name "icon-name")) edit-redo-symbolic)))
         (child
             (object (@ (class "GtkSeparator"))
               (style (class (@ (name "spacer"))))))
         (child
             (object (@ (class "GtkMenuButton"))
               (property (@ (name "icon-name")) view-more-symbolic)
               (property (@ (name "menu-model")) demo-menu)))))))

(define %toolbar-2
  '(object (@ (class "GtkBox"))
     (property (@ (name "tooltip-text")) "toolbar, osd")
     (style (class (@ (name "toolbar")))
            (class (@ (name "osd"))))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) media-skip-backward-symbolic)))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) media-playback-pause-symbolic)))
     (child
         (object (@ (class "GtkButton"))
           (property (@ (name "icon-name")) media-skip-forward-symbolic)))
     (child
         (object (@ (class "GtkScale"))
           (property (@ (name "hexpand")) True)
           (property (@ (name "adjustment"))
             (object (@ (class "GtkAdjustment"))
               (property (@ (name "lower")) 0)
               (property (@ (name "upper")) 100)
               (property (@ (name "value")) 50)))))
     (child
         (object (@ (class "GtkScaleButton"))
           (property (@ (name "icons")) "audio-volume-muted\naudio-volume-high\naudio-volume-low\naudio-volume-medium")))))

(define %toolbars
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Toolbars)
     (property (@ (name "description")
                  (translatable "yes")) "The \"toolbar\" style class on GtkBox and similar containers gives the same padding, spacing and button appearance as GtkHeaderBar and GtkActionBar have. A toolbar can additionally have the \"osd\" style class, useful for floating media controls.

The \"raised\" style class can be used to make a button inside a toolbar use default appearance instead.")
     (child ,%toolbar-1)
     (child ,%toolbar-2)))


(define %background-items
  '((child
        (object (@ (class "AdwBin"))
          (property (@ (name "tooltip-text")) background)
          (style (class (@ (name "background"))))
          (property (@ (name "child"))
            (object (@ (class "GtkLabel"))
              (property (@ (name "label")
                           (translatable "yes")) Background)
              (property (@ (name "wrap")) True)
              (property (@ (name "wrap-mode")) word-char)))))
    (child
        (object (@ (class "AdwBin"))
          (property (@ (name "tooltip-text")) view)
          (style (class (@ (name "view"))))
          (property (@ (name "child"))
            (object (@ (class "GtkLabel"))
              (property (@ (name "label")
                           (translatable "yes")) View)
              (property (@ (name "wrap")) True)
              (property (@ (name "wrap-mode")) word-char)))))
    (child
        (object (@ (class "AdwBin"))
          (property (@ (name "tooltip-text")) osd)
          (style (class (@ (name "osd"))))
          (property (@ (name "child"))
            (object (@ (class "GtkLabel"))
              (property (@ (name "label")
                           (translatable "yes")) Osd)
              (property (@ (name "wrap")) True)
              (property (@ (name "wrap-mode")) word-char)))))))

(define %backgrounds
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Backgrounds)
     (property (@ (name "description")
                  (translatable "yes")) "These style classes can be applied to any widgets that need the specific background and text color.")
     (child
         (object (@ (class "GtkBox"))
           (property (@ (name "homogeneous")) True)y
           (property (@ (name "height-request")) 100)
           ,@%background-items))))


(define %misc-status-pages
  '(object (@ (class "AdwActionRow")
              (id "status-pages-action-row"))
     (property (@ (name "title")
                  (translatable "yes")) "Status Pages")
     (property (@ (name "activatable")) True)
     #;(property (@ (name "action-name")) style.status-page)
     (child
         (object (@ (class "GtkImage"))
           (property (@ (name "icon-name")) go-next-symbolic)
           (style (class (@ (name "dim-label"))))))))

(define %misc-sidebar
  '(object (@ (class "AdwActionRow")
              (id "sidebar-action-row"))
     (property (@ (name "title")
                  (translatable "yes")) Sidebar)
     (property (@ (name "activatable")) True)
     #;(property (@ (name "action-name")) style.status-page)
     (child
         (object (@ (class "GtkImage"))
           (property (@ (name "icon-name")) go-next-symbolic)
           (style (class (@ (name "dim-label"))))))))

(define %misc-devel-switch
  '(object (@ (class "AdwSwitchRow")
              (id "devel-switch-row"))
     (property (@ (name "title")
                  (translatable "yes")) "Development Window")
     (property (@ (name "subtitle")
                  (translatable "yes")) "\"devel\" style class on GtkWindow")
     #;(property (@ (name "action-name")) style.devel)))

(define %misc-progress-bar
  '(object (@ (class "AdwSwitchRow")
              (id "progress-bar-switch-row"))
     (property (@ (name "title")
                  (translatable "yes")) "OSD Progress Bar")
     (property (@ (name "subtitle")
                  (translatable "yes")) "\"osd\" style class on GtkProgressBar")
     #;(property (@ (name "action-name")) style.progress)))

(define %misc
  `(object (@ (class "AdwPreferencesGroup"))
     (property (@ (name "title")
                  (translatable "yes")) Misc)
     (child ,%misc-status-pages)
     (child ,%misc-sidebar)
     (child ,%misc-devel-switch)
     (child ,%misc-progress-bar)))


(define %navigation-view-demo-window
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwStyleClassesDemoWindow")
                 (parent "AdwWindow"))
      (property (@ (name "modal")) True)
      (property (@ (name "default-width")) 800)
      (property (@ (name "default-height")) 640)
      (property (@ (name "width-request")) 360)
      (property (@ (name "height-request")) 150)
      (property (@ (name "title")
                   (translatable "yes")) "Style Classes")
      (property (@ (name "content"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))))
          (property (@ (name "content"))
            (object (@ (class "GtkOverlay"))
              (child (@ (type "overlay"))
                ,%progress-bar)
              (child
                  (object (@ (class "AdwPreferencesPage"))
                    (property (@ (name "width-request")) 360)
                    (property (@ (name "description")
                                 (translatable "yes")) "Hover over widgets to see their exact style class names.")
                    (child ,%buttons)
                    (child ,%entries)
                    (child ,%linked-controls)
                    (child ,%labels)
                    (child ,%cards-and-boxed-lists)
                    (child ,%app-icons)
                    (child ,%check-buttons)
                    (child ,%toolbars)
                    (child ,%backgrounds)
                    (child ,%misc)))))))
      (child
          (object (@ (class "AdwBreakpoint"))
            (condition "max-width: 500sp")
            (setter (@ (object "button-box-1")
                       (property "orientation")) vertical)
            (setter (@ (object "button-box-2")
                       (property "orientation")) vertical)
            (setter (@ (object "entry-box-1")
                       (property "orientation")) vertical)
            (setter (@ (object "entry-box-2")
                       (property "orientation")) vertical)
            (setter (@ (object "label-box")
                       (property "orientation")) vertical)
            (setter (@ (object "label-box")
                       (property "spacing")) 12))))
    ,%demo-menu
    ,%status-pages
    ,%sidebar))


(define (make-ui)
  (sxml->ui %navigation-view-demo-window))
