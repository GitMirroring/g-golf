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


(define-module (pages about about)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  
  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-about>))


#;(g-export )


(define-class <adw-demo-page-about> (<adw-bin>)
  ;; child-id slot(s)
  (about-button #:accessor !about-button #:child-id "about-button")
  ;; slot(s)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/about/about-ui.ui")
  #:child-ids '("about-button"))


(define-method (initialize (self <adw-demo-page-about>) initargs)
  (next-method)

  (connect (!about-button self)
           "clicked"
           (lambda (b)
             (about-dialog-cb self))))

(define %developers
  '("Angela Avery <angela@example.org>"))

(define %artists
  '("GNOME Design Team"))

(define %special-thanks
  '("My cat"))

(define %release-notes "
<p>
  This release adds the following features:
</p>
<ul>
  <li>Added a way to export fonts.</li>
  <li>Better support for <code>monospace</code> fonts.</li>
  <li>Added a way to preview <em>italic</em> text.</li>
  <li>Bug fixes and performance improvements.</li>
  <li>Translation updates.</li>
</ul>
  ")

(define (about-dialog-cb self) ;; demo-page-about
  (let ((about (make <adw-about-dialog>
                 #:transient-for self
                 #:application-icon "org.example.Typeset"
                 #:application-name "Typeset"  ;(G_ "Typeset")
                 #:developer-name "Angela Avery"
                 #:version "1.2.3"
                 #:release-notes %release-notes
                 #:comments "Typeset is an app that doesn’t exist and is used as an example content for this about window." ;; (G_ ...)
                 #:website "https://example.org"
                 #:issue-url "https://example.org"
                 #:support-url "https://example.org"
                 #:copyright "© 2022 Angela Avery"
                 #:license-type 'lgpl-2-1
                 #:developers %developers
                 #:artists '("GNOME Design Team")
                 ;; #:translator-credits "translator-credits"
                 )))
    (add-link about "_Documentation"
              "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/class.AboutDialog.html")
    (add-legal-section about "Fonts"
                       #f
                       'custom
                       "This application uses font data from <a href='https://example.org'>somewhere</a>.")
    (add-acknowledgement-section about
                                 "Special thanks to" ;; (G_ ...)
                                 %special-thanks)
    (present about self)))
