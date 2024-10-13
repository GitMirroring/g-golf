;; -*- mode: scheme; coding: utf-8 -*-

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


(define-module (adw-demo-window)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (adw-demo-debug-info)
  #:use-module (adw-demo-preferences)
  #:use-module (adw-demo-pages)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-window>
            activate-demo))


#;(g-export !toast-overlay
          !split-view
          !color-scheme-button
          !content
          !stack)


(define-class <adw-demo-window> (<adw-application-window>)
  ;; slots
  (toast-overlay #:accessor !toast-overlay #:child-id "toast-overlay")
  (split-view #:accessor !split-view #:child-id "split-view")
  (color-scheme-button #:accessor !color-scheme-button
                       #:child-id "color-scheme-button")
  (content #:accessor !content #:child-id "content")
  (stack #:accessor !stack #:child-id "stack")
  (toasts-page #:accessor !toasts-page #:child-id "toasts-page")
  ;; class options
  #:template (string-append %adw-demo-path
                            "/adw-demo-window-ui.ui")
  #:child-ids '("toast-overlay"
                "split-view"
                "color-scheme-button"
                "content"
                "stack"
                "toasts-page"))

(define-method (initialize (self <adw-demo-window>) initargs)
  (next-method)
  (install-actions self)
  (install-shortcuts self))


;;;
;;; install actions
;;;

(define (install-actions demo-window)
  (let ((action-map (make <g-simple-action-group>))
        (a-undo (make <g-simple-action> #:name "undo")))

    (add-action action-map a-undo)
    (connect a-undo
             'activate
             (lambda (s-action g-variant)
               (toast/undo demo-window)))

    (insert-action-group demo-window
                         "toast"
                         action-map)))

(define (toast/undo demo-window)
  (undo (!toasts-page demo-window)))

(define (install-app-actions app)
  (let ((a-inspector (make <g-simple-action> #:name "inspector"))
        (a-preferences (make <g-simple-action> #:name "preferences"))
        (a-about (make <g-simple-action> #:name "about"))
        (a-quit (make <g-simple-action> #:name "quit")))

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
               (app/show-about app)))

    (add-action app a-quit)
    (connect a-quit
             'activate
             (lambda (s-action g-variant)
               (app/quit app)))
    (set-accels-for-action app "app.quit" '("<Ctrl>Q"))))


;;;
;;; install shortcuts
;;;

(define (install-shortcuts demo-window)
  (let ((controller (make <gtk-shortcut-controller>
                      #:name "demo-window-shortcuts")))
    (set-scope controller 'local)
    (add-controller demo-window controller)
    (for-each (match-lambda
                ((key-name modifiers action-name)
                 (let ((key-value
                        (gi-import-by-name "Gdk" key-name #:allow-constant? #t)))
                   (add-shortcut controller
                                 (make <gtk-shortcut>
                                   #:trigger (make <gtk-keyval-trigger>
                                               #:keyval key-value
                                               #:modifiers modifiers)
                                   #:action (make <gtk-named-action>
                                              #:action-name action-name))))))
        '(("KEY_w" (control-mask)  "window.close")))))


;;;
;;;
;;;

(define %developers
  '("Adrien Plazas"
    "Alexander Mikhaylenko"
    "Andrei Lișiță"
    "Guido Günther"
    "Jamie Murphy"
    "Julian Sparber"
    "Manuel Genovés"
    "Zander Brown"))

(define (app/show-about app)
  (let* ((active-window (get-active-window app))
         (about (make <adw-about-dialog>
                  #:transient-for active-window
                  #:application-icon "org.gnome.Adwaita1.Demo"
                  #:application-name "Adwaita Demo"
                  #:developer-name "The GNOME Project"
                  #:version (adw-version)
                  #:website "https://gitlab.gnome.org/GNOME/libadwaita"
                  #:issue-url "https://gitlab.gnome.org/GNOME/libadwaita/-/issues/new"
                  #:debug-info (debug-info)
                  #:copyright "© 2017–2022 Purism SPC\n© 2023-2024 GNOME Foundation Inc."
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
    (present about active-window)))

(define (app/quit app)
  (exit))

(define (activate-demo app)
  (let* ((cwd (dirname (current-filename)))
         (display (gdk-display-get-default))
         (manager (adw-style-manager-get-default))
         (icon-theme (gtk-icon-theme-get-for-display display)))
    (add-search-path icon-theme (string-append cwd "/icons"))
    (let* ((window (make <adw-demo-window>
                     #:application app))
           (color-scheme-button (!color-scheme-button window))
           (expression (make-expression 'string
                                        (transform-to-closure)
                                        '())))
      (install-app-actions app)

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
  (let* ((stack (!stack window))
         (child (get-visible-child stack))
         (page (get-page stack child)))
    (set-title (!content window) (get-title page))
    (set-show-content (!split-view window) #t)))
