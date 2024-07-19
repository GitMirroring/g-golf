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


(define-module (adw-demo-init)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (%adw-demo-path))


(eval-when (expand load eval)
  (for-each (lambda (name)
              (gi-import-by-name "Gio" name))
      '("SimpleActionGroup"
        "SimpleAction"
        "ActionMap"
        "Menu"
        "MenuItem"
        "Icon"
        "ThemedIcon"
        "File"
         "FileQueryInfoFlags"))
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gsk" name))
      '("Transform"))
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Display"
        "DragAction"
        "ModifierType"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Root"
        "Widget"
        "Window"
        "ScrolledWindow"
        "FileDialog"
        "ClosureExpression"
        "Adjustment"
        "IconTheme"
        "Stack"
        "StackSwitcher"
        "StackPage"
        "Box"
        "ListBox"
        "Button"
        "ToggleButton"
        "Label"
        "Image"
        "PackType"
        "Orientation"
        "CustomLayout"
        "TextDirection"
        "StringList"
        "StringObject"
        "ShortcutController"
        "Shortcut"
        "ShortcutScope"
        "NamedAction"
        "KeyvalTrigger"
        "License"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Application"
        "ApplicationWindow"
        "Window"
        "AboutWindow"
        "StyleManager"
        "ColorScheme"
        "Bin"
        "Avatar"
        "Clamp"
        "Carousel"
        "PreferencesGroup"
        "StatusPage"
        "NavigationSplitView"
        "OverlaySplitView"
        "Dialog"
        "AlertDialog"
        "ResponseAppearance"
        "TabView"
        "TabPage"
        "TabBar"
        "TabOverview"
        "Toast"
        "ToastOverlay"
        "ActionRow"
        "SwitchRow"
        "SpinRow"
        "ComboRow"
        "EntryRow"
        "ExpanderRow"
        "ButtonContent"
        "EnumListModel"
        "EnumListItem"
        "LengthUnit"
        "Animation"
        "TimedAnimation"
        "SpringAnimation"
        "AnimationState"
        "CallbackAnimationTarget"
        "Easing")))


(define %adw-demo-path
  (dirname (current-filename)))
