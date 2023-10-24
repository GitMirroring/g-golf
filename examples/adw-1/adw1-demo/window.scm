;; -*- mode: scheme; coding: utf-8 -*-

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


(define-module (adw1-demo window)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw1-demo debug-info)
  #:use-module (adw1-demo preferences)
  #:use-module (adw1-demo welcome)
  #:use-module (adw1-demo navigation-view)
  #:use-module (adw1-demo style-classes)
  #:use-module (adw1-demo dialogs)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-window>
            show-window))


(g-export !split-view
          !color-scheme-button
          !stack)


(eval-when (expand load eval)
  (for-each (lambda (name)
              (gi-import-by-name "Gio" name))
      '("SimpleAction"))
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Display"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("License"
        "Window"
        "StyleContext"
        "CssProvider"
        "ClosureExpression"
        "IconTheme"
        "Stack"
        "Button"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Application"
        "ApplicationWindow"
        "AboutWindow"
        "StyleManager"
        "ColorScheme"
        "NavigationSplitView")))


(define-class <adw-demo-window> (<adw-application-window>)
  ;; slots
  (split-view #:accessor !split-view #:child-id "split-view")
  (color-scheme-button #:accessor !color-scheme-button #:child-id "color-scheme-button")
  (stack #:accessor !stack #:child-id "stack")
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/window.ui")
  #:child-ids '("split-view"
                "color-scheme-button"
                "stack"))

(define (install-actions app)
  (let ((a-inspector (make <g-simple-action> #:name "inspector"))
        (a-preferences (make <g-simple-action> #:name "preferences"))
        (a-about (make <g-simple-action> #:name "about")))

    (add-action app a-inspector)
    (connect a-inspector
             'activate
             (lambda (s-action g-variant)
               (gtk-window-set-interactive-debugging #t)))

    (add-action app a-preferences)
    (connect a-preferences
             'activate
             (lambda (s-action g-variant)
               (let ((window (get-active-window app))
                     (pref-win (make <adw-demo-preferences-window>)))
                 (set-transient-for pref-win window)
                 (present pref-win))))

    (add-action app a-about)
    (connect a-about
             'activate
             (lambda (s-action g-variant)
               (show-about app)))))

(define %developers
  '("Adrien Plazas"
    "Alexander Mikhaylenko"
    "Andrei Lișiță"
    "Guido Günther"
    "Jamie Murphy"
    "Julian Sparber"
    "Manuel Genovés"
    "Zander Brown"))

(define (show-about app)
  (let ((about (make <adw-about-window>
                 #:transient-for (get-active-window app)
                 #:application-icon "org.gnome.Adwaita1.Demo"
                 #:application-name "Adwaita Demo"
                 #:developer-name "The GNOME Project"
                 #:version (adw-version)
                 #:website "https://gitlab.gnome.org/GNOME/libadwaita"
                 #:issue-url "https://gitlab.gnome.org/GNOME/libadwaita/-/issues/new"
                 #:debug-info (debug-info)
                 #:copyright "© 2017–2022 Purism SPC"
                 #:license-type 'lgpl-2-1
                 #:developers %developers
                 #:designers '("GNOME Design Team")
                 #:artists '("GNOME Design Team")
                 ;; #:translator-credits "translator-credits"
                 )))
    (add-link about "_Documentation"
              "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/")
    (add-link about "_Chat"
              "https://matrix.to/#/#libadwaita:gnome.org")
    (present about)))

(define (show-window app)
  (let* ((cwd (dirname (current-filename)))
         (display (gdk-display-get-default))
         (manager (adw-style-manager-get-default))
         (icon-theme (gtk-icon-theme-get-for-display display))
         (css-path (string-append cwd "/css/style.css"))
         (css-provider (let ((provider (make <gtk-css-provider>)))
                         (gtk-css-provider-load-from-path provider css-path)
                         provider)))
    (add-search-path icon-theme (string-append cwd "/icons"))
    (gtk-style-context-add-provider-for-display display css-provider 800)
    (let* ((window (make <adw-demo-window>
                     #:application app))
           (color-scheme-button (!color-scheme-button window))
           (expression (make-expression 'string
                                        (transform-to-closure)
                                        '())))

      (install-actions app)

      (bind expression
            color-scheme-button
            "icon-name"
            manager)

      (connect color-scheme-button
               'clicked
               (lambda (b)
                 (if (get-dark manager)
                     (set-color-scheme manager 'force-light)
                     (set-color-scheme manager 'force-dark))))

      (connect manager
               'notify::system-supports-color-schemes
               (lambda (manager p-spec)
                 (notify-system-supports-color-schemes-cb window manager)))
      (notify-system-supports-color-schemes-cb window manager)

      (connect-after (!stack window)
                     'notify::visible-child
                     (lambda (stack p-spec)
                       (notify-visible-child-cb window)))

      (present window))))

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))

(define (transform-to-closure)
  (make <closure>
    #:function manager-dark-transform-to
    #:return-type 'string
    #:param-types `(,<adw-style-manager>)))

(define (manager-dark-transform-to manager)
  (color-scheme-button-icon-name (!dark manager)))

(define (color-scheme-button-icon-name dark?)
  (if dark?
      "dark-mode-symbolic"
      "light-mode-symbolic"))

(define* (notify-system-supports-color-schemes-cb window
                                                  #:optional manager)
  (let* ((manager (or manager (adw-style-manager-get-default)))
         (supports? (get-system-supports-color-schemes manager)))
    (set-visible (!color-scheme-button window) (not supports?))
    (when supports?
      (set-color-scheme manager 'default))))

(define (notify-visible-child-cb window)
  (set-show-content (!split-view window) #t))
