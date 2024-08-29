;; -*- mode: scheme; coding: utf-8 -*-

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


(define-module (pages tab-view tab-view-demo-window)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages tab-view tab-view-demo-page)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-tab-view-demo-window>))


;; Although technically this module only needs to export the prepopulate
;; method, used by the (adw1-demo tab-view) module, I need 'more' while
;; in devel/debug mode.
(g-export !view
          !tab-bar
          !tab-overview
          !tab-menu

          !menu-page
          !tab-action-group
          !in-dispose

          add-page
          prepopulate)


(define-class <adw-tab-view-demo-window> (<adw-window>)
  ;; child-id slot(s) (that we need to access)
  (view #:child-id "view" #:accessor !view)
  (tab-bar #:child-id "tab-bar" #:accessor !tab-bar)
  (tab-overview #:child-id "tab-overview" #:accessor !tab-overview)
  (tab-menu #:child-id "tab-menu" #:accessor !tab-menu)
  ;; slot(s)
  (menu-page #:accessor !menu-page #:init-value #f)
  (tab-action-group #:accessor !tab-action-group)
  (in-dispose #:accessor !in-dispose #:init-value #f)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/tab-view/tab-view-demo-window-ui.ui")
  #:child-ids '("view"
                "tab-bar"
                "tab-overview"
                "tab-menu"))

(define-vfunc (dispose-vfunc (self <adw-tab-view-demo-window>))
  (set! (!in-dispose self) #t)
  (unref (!tab-action-group self))
  (next-vfunc))

(define-method (initialize (self <adw-tab-view-demo-window>) initargs)
  (next-method)
  (install-actions self)
  (install-shortcuts self)
  (install-extra-drop-targets self)
  (install-callbacks self))

(define-method (add-page (self <adw-tab-view-demo-window>) parent content)
  (let* ((view (!view self))
         (page (add-page view content parent)))
    (bind-property content "title" page "title" '(sync-create bidirectional))
    (bind-property content "icon" page "icon" '(sync-create))
    (bind-property-full content "title"	;; source // p-name
                        page "tooltip"	;; target // p-name
                        '(sync-create)	;; flags
                        text-to-tooltip ;; tranform to
                        #f)		;; transfrom from
    (set-indicator-activatable page #t)
    (set-thumbnail-xalign page 0.5)
    (set-thumbnail-yalign page 0.5)
    page))

(define-method (prepopulate (self <adw-tab-view-demo-window>))
  (win/tab-new self)
  (win/tab-new self)
  (win/tab-new self)
  (invalidate-thumbnails (!view self)))


;;;
;;; install actions
;;;

(define (install-actions tab-view-demo-window)
  (install-win-actions tab-view-demo-window)
  (install-tab-actions tab-view-demo-window))


;; win action group and callback(s)

(define (install-win-actions tab-view-demo-window)
  (let ((action-map (make <g-simple-action-group>))
        (a-window-new (make <g-simple-action> #:name "window-new"))
        (a-tab-new (make <g-simple-action> #:name "tab-new")))

    (add-action action-map a-window-new)
    (connect a-window-new
             'activate
             (lambda (s-action g-variant)
               (win/window-new tab-view-demo-window)))

    (add-action action-map a-tab-new)
    (connect a-tab-new
             'activate
             (lambda (s-action g-variant)
               (win/tab-new tab-view-demo-window)))

    (insert-action-group tab-view-demo-window
                         "win"
                         action-map)))

(define (win/window-new tab-view-demo-window)
  (let ((new-tab-view-demo-window (make <adw-tab-view-demo-window>)))
    (prepopulate new-tab-view-demo-window)
    (present new-tab-view-demo-window)))

(define (win/tab-new tab-view-demo-window)
  (let* ((view (!view tab-view-demo-window))
         (page (create-tab-cb tab-view-demo-window))
         (content (get-child page)))
    (set-selected-page view page)
    (grab-focus content)))

(define (install-tab-actions tab-view-demo-window)
  (let ((action-map (make <g-simple-action-group>))
        (a-move-to-new-window (make <g-simple-action>
                                #:name "move-to-new-window"))
        (a-duplicate (make <g-simple-action> #:name "duplicate"))
        (a-pin (make <g-simple-action> #:name "pin"))
        (a-unpin (make <g-simple-action> #:name "unpin"))
        (a-icon (g-simple-action-new-stateful "icon"
                                              #f ;; (g-variant-type-new "b")
                                              (g-variant-new-boolean #t)))
        (a-refresh-icon (make <g-simple-action> #:name "refresh-icon"))
        (a-loading (g-simple-action-new-stateful "loading"
                                                 #f
                                                 (g-variant-new-boolean #t)))
        (a-needs-attention (g-simple-action-new-stateful "needs-attention"
                                                         #f
                                                         (g-variant-new-boolean #t)))
        (a-indicator (g-simple-action-new-stateful "indicator"
                                                   #f ;; (g-variant-type-new "b")
                                                   (g-variant-new-boolean #f)))
        (a-close-other (make <g-simple-action> #:name "close-other"))
        (a-close-before (make <g-simple-action> #:name "close-before"))
        (a-close-after (make <g-simple-action> #:name "close-after"))
        (a-close (make <g-simple-action> #:name "close")))

    (add-action action-map a-move-to-new-window)
    (connect a-move-to-new-window
             'activate
             (lambda (s-action g-variant)
               (tab/move-to-new-window tab-view-demo-window)))

    (add-action action-map a-duplicate)
    (connect a-duplicate
             'activate
             (lambda (s-action g-variant)
               (tab/duplicate tab-view-demo-window)))

    (add-action action-map a-pin)
    (connect a-pin
             'activate
             (lambda (s-action g-variant)
               (tab/pin tab-view-demo-window s-action g-variant)))

    (add-action action-map a-unpin)
    (connect a-unpin
             'activate
             (lambda (s-action g-variant)
               (tab/unpin tab-view-demo-window s-action g-variant)))

    (add-action action-map a-icon)
    (connect a-icon
             'activate
             (lambda (s-action g-variant)
               (tab/icon tab-view-demo-window s-action g-variant)))

    (add-action action-map a-refresh-icon)
    (connect a-refresh-icon
             'activate
             (lambda (s-action g-variant)
               (tab/refresh-icon tab-view-demo-window s-action g-variant)))

    (add-action action-map a-loading)
    (connect a-loading
             'activate
             (lambda (s-action g-variant)
               (tab/loading tab-view-demo-window s-action g-variant)))

    (add-action action-map a-needs-attention)
    (connect a-needs-attention
             'activate
             (lambda (s-action g-variant)
               (tab/needs-attention tab-view-demo-window s-action g-variant)))

    (add-action action-map a-indicator)
    (connect a-indicator
             'activate
             (lambda (s-action g-variant)
               (tab/indicator tab-view-demo-window s-action g-variant)))

    (add-action action-map a-close-other)
    (connect a-close-other
             'activate
             (lambda (s-action g-variant)
               (tab/close-other tab-view-demo-window s-action g-variant)))

    (add-action action-map a-close-before)
    (connect a-close-before
             'activate
             (lambda (s-action g-variant)
               (tab/close-before tab-view-demo-window s-action g-variant)))

    (add-action action-map a-close-after)
    (connect a-close-after
             'activate
             (lambda (s-action g-variant)
               (tab/close-after tab-view-demo-window s-action g-variant)))

    (add-action action-map a-close)
    (connect a-close
             'activate
             (lambda (s-action g-variant)
               (tab/close tab-view-demo-window s-action g-variant)))

    (set! (!tab-action-group tab-view-demo-window) action-map)
    (insert-action-group tab-view-demo-window
                         "tab"
                         action-map)))

(define (tab/move-to-new-window tab-view-demo-window)
  (let ((new-tab-view-demo-window (make <adw-tab-view-demo-window>)))
    (transfer-page (!view tab-view-demo-window)
                   (!menu-page tab-view-demo-window)
                   (!view new-tab-view-demo-window)
                   0)
    (present new-tab-view-demo-window)))

(define (tab/duplicate tab-view-demo-window)
  (let* ((view (!view tab-view-demo-window))
         (parent (get-current-page tab-view-demo-window))
         (parent-content (get-child parent))
         (page (add-page tab-view-demo-window
                         parent
                         (duplicate parent-content)))
         (content (get-child page))
         (indicator? (!indicator? content)))
    (set-indicator-icon page (get-indicator-icon parent))
    (set-indicator-tooltip page (get-indicator-tooltip parent))
    (set-loading page (get-loading parent))
    (set-needs-attention page (get-needs-attention parent))
    (set-selected-page (!view tab-view-demo-window) page)
    page))

(define (tab/pin tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (set-page-pinned view page #t)))

(define (tab/unpin tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (set-page-pinned view page #f)))

(define (tab/icon tab-view-demo-window s-action g-variant)
  (let* ((page (get-current-page tab-view-demo-window))
         (content (get-child page)))
    (toggle-enable-icon content)
    (set-state s-action
               (g-variant-new-boolean (!icon? content)))))

(define (tab/refresh-icon tab-view-demo-window s-action g-variant)
  (let* ((page (get-current-page tab-view-demo-window))
         (content (get-child page)))
    (refresh-icon content)))

(define (tab/loading tab-view-demo-window s-action g-variant)
  (let* ((page (get-current-page tab-view-demo-window))
         (content (get-child page))
         (loading? (toggle-enable-loading content)))
      (set-loading page loading?)
      (set-state s-action
                 (g-variant-new-boolean loading?))))

(define (tab/needs-attention tab-view-demo-window s-action g-variant)
  (let* ((page (get-current-page tab-view-demo-window))
         (content (get-child page))
         (needs-attention? (toggle-enable-needs-attention content)))
      (set-needs-attention page needs-attention?)
      (set-state s-action
                 (g-variant-new-boolean needs-attention?))))

(define (tab/indicator tab-view-demo-window s-action g-variant)
  (let* ((page (get-current-page tab-view-demo-window))
         (content (get-child page)))
    (toggle-enable-indicator content)
    (let ((indicator? (!indicator? content)))
      (set-indicator-icon page
                          (and indicator?
                               (get-indicator-icon content)))
      (set-indicator-tooltip page
                             (if indicator?
                                 (get-indicator-tooltip content)
                                 ""))
      (set-state s-action
                 (g-variant-new-boolean indicator?)))))

(define (tab/close-other tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (close-other-pages view page)))

(define (tab/close-before tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (close-pages-before view page)))

(define (tab/close-after tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (close-pages-after view page)))

(define (tab/close tab-view-demo-window s-action g-variant)
  (let ((view (!view tab-view-demo-window))
        (page (get-current-page tab-view-demo-window)))
    (close-page view page)))


;;;
;;; install shortcuts
;;;

(define (install-shortcuts tab-view-demo-window)
  (let ((controller (make <gtk-shortcut-controller>)))
    (set-scope controller 'managed)
    (add-controller tab-view-demo-window controller)
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
        '(("KEY_n" (control-mask)  "win.window-new")
          ("KEY_t" (control-mask)  "win.tab-new")
          ("KEY_w" (control-mask)  "tab.close")))))


;;;
;;; install extra drop targets
;;;

(define (install-extra-drop-targets tab-view-demo-window)
  (let ((tab-bar (!tab-bar tab-view-demo-window))
        (tab-overview (!tab-overview tab-view-demo-window)))
    (setup-extra-drop-target tab-bar
                             '(copy)
                             '(string))
    (setup-extra-drop-target tab-overview
                             '(copy)
                             '(string))))


;;;
;;; callback
;;;

(define (install-callbacks self) ;; tab-view-demo-window
  (let* ((display (get-display self))
         (style-manager (adw-style-manager-get-for-display display))
         (view (!view self))
         (tab-bar (!tab-bar self))
         (tab-overview (!tab-overview self)))
    #;(connect view
             "page-detached"
             (lambda (view page pos)
               (page-detached-cb self view page pos)))
    (connect view
             "setup-menu"
             (lambda (view page)
               (setup-menu-cb self view page)))
    (connect view
             "create-window"
             (lambda (view page)
               (create-window-cb self view page)))
    (connect view
             "indicator-activated"
             (lambda (view page)
               (indicator-activated-cb self view page)))
    (connect tab-bar
             "extra-drag-drop"
             (lambda (bar page value)
               (extra-drag-drop-cb self page value)))
    (connect tab-overview
             "create-tab"
             (lambda (tab-overview)
               (create-tab-cb self)))
    (connect tab-overview
             "extra-drag-drop"
             (lambda (overview page value)
               (extra-drag-drop-cb self page value)))
    (connect style-manager
             "notify::dark"
             (lambda (manager p-spec)
               (invalidate-thumbnails view)))
    (connect style-manager
             "notify::high-contrast"
             (lambda (manager p-spec)
               (invalidate-thumbnails view)))))

#;(define (page-detached-cb tab-view-demo-window view page pos)
  (dimfi 'page-detached-cb)
  (dimfi " " tab-view-demo-window view page pos)
  (dimfi " " 'tab-overview (!tab-overview tab-view-demo-window))
  (dimfi " " 'in-dispose (!in-dispose tab-view-demo-window))
  (unless (!in-dispose tab-view-demo-window)
    (when (and (> (get-n-pages view) 0)
               (not (get-open (!tab-overview tab-view-demo-window))))
      (close tab-view-demo-window))))

(define (setup-menu-cb tab-view-demo-window view page)
  (let* ((pinned (and page (get-pinned page)))
         (pos (and page (get-page-position view page)))
         (prev (and pos (> pos 0) (get-nth-page view (- pos 1))))
         (prev-pinned (and prev (get-pinned prev)))
         (n-page (get-n-pages view))
         (can-close-before (and (not pinned) prev (not prev-pinned)))
         (can-close-after (and pos (< pos (- n-page 1))))
         (has-icon (and page (get-icon page))))
    (set! (!menu-page tab-view-demo-window) page)
    (set-tab-action-enabled tab-view-demo-window
                            "move-to-new-window"
                            (or (not page)
                                (and (not pinned)
                                     (> n-page 1))))
    (set-tab-action-enabled tab-view-demo-window
                            "pin"
                            (or (not page) (not pinned)))
    (set-tab-action-enabled tab-view-demo-window
                            "unpin"
                            (or (not page) pinned))
    (set-tab-action-enabled tab-view-demo-window "refresh-icon" has-icon)
    (set-tab-action-enabled tab-view-demo-window
                            "close-other"
                            (or can-close-before can-close-after))
    (set-tab-action-enabled tab-view-demo-window
                            "close-before"
                            can-close-before)
    (set-tab-action-enabled tab-view-demo-window
                            "close-after"
                            can-close-after)
    (when page
      (set-tab-action-state tab-view-demo-window "icon" has-icon)
      (set-tab-action-state tab-view-demo-window "loading"
                            (get-loading page))
      (set-tab-action-state tab-view-demo-window "needs-attention"
                            (get-needs-attention page))
      (set-tab-action-state tab-view-demo-window "indicator"
                            (get-indicator-icon page)))))

(define (create-window-cb tab-view-demo-window view page)
  (present (make <adw-tab-view-demo-window>)))

(define (indicator-activated-cb tab-view-demo-window view page)
  (let* ((content (get-child page))
         (muted? (!muted? content)))
    (toggle-muted content)
    (set-indicator-icon page (get-indicator-icon content))
    (set-indicator-tooltip page (get-indicator-tooltip content))))

(define create-tab-cb #f)

(let ((next-page 1))
  (set! create-tab-cb
        (lambda (tab-view-demo-window)
          (let* ((title (format #f "Tab ~A" next-page))
                 (content (make <adw-tab-view-demo-page>
                            #:title title)))
            (set! next-page (+ next-page 1))
            (add-page tab-view-demo-window #f content)))))

(define (extra-drag-drop-cb tab-view-demo-window page value)
  (set-title page value)
  #t)  ;; yes, stop the propagation of this event


;;;
;;; utils
;;;

(define (get-current-page tab-view-demo-window)
  (or (!menu-page tab-view-demo-window)
      (get-selected-page (!view tab-view-demo-window))))

(define (text-to-tooltip binding input output)
  (let* ((title (g-value-get-string input))
         (tooltip (format #f "Elaborate tooltip for <b>~A</b>"
                          (g-markup-escape-text title))))
    (g-value-set-string output tooltip)
    #t))

(define (set-tab-action-enabled tab-view-demo-window name enabled?)
  (let* ((action-group (!tab-action-group tab-view-demo-window))
         (action (lookup-action action-group name)))
    (and action
         (set-enabled action enabled?))))

(define (set-tab-action-state tab-view-demo-window name state?)
  (let* ((action-group (!tab-action-group tab-view-demo-window))
         (action (lookup-action action-group name)))
    (and action
         (set-state action
                    (g-variant-new-boolean state?)))))
