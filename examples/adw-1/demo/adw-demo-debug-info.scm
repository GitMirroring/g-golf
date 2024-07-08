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


(define-module (adw-demo-debug-info)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (adw-version
            debug-info))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Display"))
  (for-each (lambda (name)
              (gi-import-by-name "Gsk" name))
      '("Renderer"))
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("get_major_version"
        "get_minor_version"
        "get_micro_version"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("get_major_version"
        "get_minor_version"
        "get_micro_version")))


(define (glib-header-version)
  (match (map gi-import-constant
           (map (lambda (item)
                  (g-irepository-find-by-name "GLib" item))
             (list "MAJOR_VERSION"
                   "MINOR_VERSION"
                   "MICRO_VERSION")))
    ((major minor micro)
     (format #f "~A.~A.~A" major minor micro))))

(define (glib-runtime-version)
  (format #f "~A.~A.~A"
          (glib-get-major-version)
          (glib-get-minor-version)
          (glib-get-micro-version)))

(define (gtk-version)
  (format #f "~A.~A.~A"
          (gtk-get-major-version)
          (gtk-get-minor-version)
          (gtk-get-micro-version)))

(define (adw-version)
  (format #f "~A.~A.~A"
          (adw-get-major-version)
          (adw-get-minor-version)
          (adw-get-micro-version)))

(define (get-gtk-backend-info)
  (let* ((display (gdk-display-get-default))
         (class (class-of display)))
    (case (class-name class)
      ((<gdk-x11-display>) "X11")
      ((<gdk-wayland-display>) "Wayland")
      ((<gdk-broadway-display>) "Broadway")
      ((<gdk-win32-display>) "Windows")
      ((<gdk-macos-display>) "MacOS")
      (else
       (g-type-name (!g-type class))))))

(define (get-gtk-renderer-info)
  (let* ((display (gdk-display-get-default))
         (surface (gdk-surface-new-toplevel display))
         (renderer (gsk-renderer-new-for-surface surface))
         (class (class-of renderer)))
    (case (class-name class)
      ((<gsk-vulkan-renderer>) "Vulkan")
      ((<gsk-gl-renderer>) "GL")
      ((<gsk-cairo-renderer>) "Cairo")
      (else
       (g-type-name (!g-type class))))))


(define %debug-info-fmt
  "Adwaita Demo - G-Golf port

Guile:
- Version: ~A

Running against:
- Libadwaita: ~A
- GLib: ~A
- GTK: ~A

System:
- Name: ~A
- Version: ~A
- Code name: ~A

GTK:
- GDK backend: ~A
- GSK renderer: ~A

Environment:
- Desktop: ~A
- Session: ~A (~A)
- Language: ~A
")


(define* (debug-info #:optional (port #f))
  (format port "~?" %debug-info-fmt
          (list (version)
                (adw-version)
                (glib-runtime-version)
                (gtk-version)
                (g-get-os-info "NAME")
                (or (g-get-os-info "VERSION")
                    " - not available - ")
                (or (g-get-os-info "VERSION_CODENAME")
                    " - not available - ")
                (get-gtk-backend-info)
                (get-gtk-renderer-info)
                (getenv "XDG_CURRENT_DESKTOP")
                (getenv "XDG_SESSION_DESKTOP")
                (getenv "XDG_SESSION_TYPE")
                (getenv "LANG"))))


#!

(call-with-output-file
    "/tmp/debug-info.txt"
  (lambda (port) (debug-info port)))

cat /tmp/debug-info.txt
=> ...

;;;
;;; surface renderer test
;;;

,use (g-golf)
(add-to-load-path "/home/david/gnu/g-golf/git/examples/adw-1")
,use (adw1-demo debug-info)
(gi-import-by-name "Adw" "init")
$3 = #<<function> 7fc7d131c5a0>

(adw-init)
(gdk-display-get-default)
$4 = #<<gdk-wayland-display> 7fc7d4cb6a20>

(gdk-surface-new-toplevel $4)
$5 = #<<gdk-wayland-toplevel> 7fc7d29741d0>

(class-precedence-list (class-of $5))
$6 = (#<<gobject-class> <gdk-wayland-toplevel> 7fc7cef72b40> #<<gobject-class> …> …)

(for-each dimfi $6)
;; #<<gobject-class> <gdk-wayland-toplevel> 7fc7cef72b40> 
;; #<<gobject-class> <gdk-wayland-surface> 7fc7cef72d20> 
;; #<<gobject-class> <gdk-surface> 7fc7d10ec960> 
;; #<<gobject-class> <gobject> 7fc7d2977e10> 
;; #<<gobject-class> <gdk-toplevel> 7fc7cef72c30> 
;; #<<gobject-class> <ginterface> 7fc7d2977d20> 
;; #<<gtype-class> <gtype-instance> 7fc7d2977f00> 
;; #<<class> <object> 7fc7dc13f380> 
;; #<<class> <top> 7fc7dc13f400> 

(gsk-renderer-new-for-surface $5)
$7 = #<<gsk-gl-renderer> 7fc7d1c29490>

!#
