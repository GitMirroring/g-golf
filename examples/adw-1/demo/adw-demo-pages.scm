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


(define-module (adw-demo-pages)
  #:use-module (oop goops)
  #:use-module (g-golf support module)
  #:use-module (pages welcome welcome)
  #:use-module (pages navigation-view navigation-view)
  #:use-module (pages clamp clamp)
  #:use-module (pages lists lists)
  #:use-module (pages view-switcher view-switcher)
  #:use-module (pages carousel carousel)
  #:use-module (pages avatar avatar)
  #:use-module (pages split-views split-views)
  #:use-module (pages tab-view tab-view)
  #:use-module (pages buttons buttons)
  #:use-module (pages style-classes style-classes)
  #:use-module (pages toasts toasts)
  ;; #:use-module (pages animations animations)
  #:use-module (pages dialogs dialogs)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last))


(eval-when (expand load eval)
  (re-export-public-interface (oop goops)
                              (pages welcome welcome)
                              (pages navigation-view navigation-view)
                              (pages clamp clamp)
                              (pages lists lists)
                              (pages view-switcher view-switcher)
                              (pages carousel carousel)
                              (pages avatar avatar)
                              (pages split-views split-views)
                              (pages tab-view tab-view)
                              (pages buttons buttons)
                              (pages style-classes style-classes)
                              (pages toasts toasts)
                              #;(pages animations animations)
                              (pages dialogs dialogs)))
