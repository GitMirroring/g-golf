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


(define %animation-clamp
  `(object (@ (class "AdwClamp")
              (id "animation-clamp"))
     (property (@ (name "maximum-size")) 400)
     (property (@ (name "tightening-threshold")) 300)
     #;(property (@ (name "child"))
       (object (@ (class "AdwBin")
                  (id "animation-scene"))
         (property (@ (name "margin-bottom")) 36)
         (property (@ (name "child"))
           (object (@ (class "AdwBin")
                      (id "animation-sample"))
             (property (@ (name "halign")) center)
             (property (@ (name "valign")) center)
             (property (@ (name "name")) animation-sample)))))))

(define %label-1
  '(object (@ (class "GtkLabel"))
     (property (@ (name "label")
                  (translatable "yes")) Animations)
     (property (@ (name "wrap")) True)
     (property (@ (name "wrap-mode")) word-char)
     (property (@ (name "justify")) center)
     (style (class (@ (name "title")))
            (class (@ (name "title-1"))))))

(define %label-2
  '(object (@ (class "GtkLabel"))
     (property (@ (name "label")
                  (translatable "yes")) "Simple Transitions")
     (property (@ (name "use-markup")) True)
     (property (@ (name "wrap")) True)
     (property (@ (name "wrap-mode")) word-char)
     (property (@ (name "justify")) center)
     (style (class (@ (name "body")))
            (class (@ (name "description"))))))

(define %skip-backward-bt
  '(object (@ (class "GtkButton")
              (id "skip-backward-bt"))
     (property (@ (name "icon-name")) media-skip-backward-symbolic)
     (property (@ (name "valign")) center)
     ;; binding - sensitive - timed-animation-can-reset
     ;; signal - clicked - timed-animation-reset - swapped
     (style (class (@ (name "circular")))
            (class (@ (name "flat"))))))

(define %play-pause-bt
  '(object (@ (class "GtkButton")
              (id "play-pause-bt"))
     ;; binding - icon-name - get-play-pause-icon-name
     (property (@ (name "width-request")) 48)
     (property (@ (name "height-request")) 48)
     ;; signal - clicked - timed-animation-play-pause - swapped
     (style (class (@ (name "circular")))
            (class (@ (name "suggested-action"))))))

(define %skip-forward-bt
  '(object (@ (class "GtkButton")
              (id "skip-forward-bt"))
     (property (@ (name "icon-name")) media-skip-forward-symbolic)
     (property (@ (name "valign")) center)
     ;; binding - sensitive - timed-animation-can-skip
     ;; signal - clicked - timed-animation-skip - swapped
     (style (class (@ (name "circular")))
            (class (@ (name "flat"))))))

(define %stack-switcher
  '(object (@ (class "GtkStackSwitcher"))
     (property (@ (name "stack")) "animation-prefs-stack")
     (property (@ (name "margin-bottom")) 32)
     (property (@ (name "halign")) center)))

(define %ta-easing
  '(object (@ (class "AdwComboRow")
              (id "ta-easing"))
     (property (@ (name "title")
                  (translatable "yes")) Easing)
     (property (@ (name "model"))
       (object (@ (class "AdwEnumListModel"))
         (property (@ (name "enum-type")) AdwEasing)))))

(define %ta-duration
  '(object (@ (class "AdwSpinRow")
              (id "ta-duration"))
     (property (@ (name "title")
                  (translatable "yes")) Duration)
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 100)
         (property (@ (name "upper")) 4000)
         (property (@ (name "value")) 500)
         (property (@ (name "page-increment")) 100)
         (property (@ (name "step-increment")) 50)))))

(define %ta-repeat-count
  '(object (@ (class "AdwSpinRow")
              (id "ta-repeat-count"))
     (property (@ (name "title")
                  (translatable "yes")) "Repeat Count")
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 10)
         (property (@ (name "value")) 1)
         (property (@ (name "page-increment")) 1)
         (property (@ (name "step-increment")) 1)))))

(define %ta-reverse
  '(object (@ (class "AdwSwitchRow")
              (id "ta-reverse"))
     (property (@ (name "title")
                  (translatable "yes")) "Reverse")))

(define %ta-alternate
  '(object (@ (class "AdwSwitchRow")
              (id "ta-alternate"))
     (property (@ (name "title")
                  (translatable "yes")) "Alternate")))

(define %stack-page-1
  `(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Timed)
     (property (@ (name "name")) Timed)
     (property (@ (name "child"))
       (object (@ (class "AdwPreferencesGroup"))
         (child ,%ta-easing)
         (child ,%ta-duration)
         (child ,%ta-repeat-count)
         (child ,%ta-reverse)
         (child ,%ta-alternate)))))

(define %sa-velocity
  '(object (@ (class "AdwSpinRow")
              (id "sa-velocity"))
     (property (@ (name "title")
                  (translatable "yes")) "Initial Velocity")
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) -1000)
         (property (@ (name "upper")) 1000)
         (property (@ (name "value")) 0)
         (property (@ (name "page-increment")) 10)
         (property (@ (name "step-increment")) 1)))))

(define %sa-damping
  '(object (@ (class "AdwSpinRow")
              (id "sa-damping"))
     (property (@ (name "title")
                  (translatable "yes")) Damping)
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 1000)
         (property (@ (name "value")) 10)
         (property (@ (name "page-increment")) 10)
         (property (@ (name "step-increment")) 1)))))

(define %sa-mass
  '(object (@ (class "AdwSpinRow")
              (id "sa-mass"))
     (property (@ (name "title")
                  (translatable "yes")) Mass)
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 100)
         (property (@ (name "value")) 1)
         (property (@ (name "page-increment")) 10)
         (property (@ (name "step-increment")) 1)))))

(define %sa-stiffness
  '(object (@ (class "AdwSpinRow")
              (id "sa-stiffness"))
     (property (@ (name "title")
                  (translatable "yes")) Stiffness)
     (property (@ (name "numeric")) True)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 0)
         (property (@ (name "upper")) 1000)
         (property (@ (name "value")) 100)
         (property (@ (name "page-increment")) 10)
         (property (@ (name "step-increment")) 1)))))

(define %sa-epsilon
  '(object (@ (class "AdwSpinRow")
              (id "sa-epsilon"))
     (property (@ (name "title")
                  (translatable "yes")) Epsilon)
     (property (@ (name "numeric")) True)
     (property (@ (name "digits")) 5)
     (property (@ (name "adjustment"))
       (object (@ (class "GtkAdjustment"))
         (property (@ (name "lower")) 0.0001)
         (property (@ (name "upper")) 0.01)
         (property (@ (name "value")) 0.001)
         (property (@ (name "page-increment")) 0.001)
         (property (@ (name "step-increment")) 0.001)))))

(define %sa-clamp-switch
  '(object (@ (class "AdwSwitchRow")
              (id "sa-clamp-switch"))
     (property (@ (name "title")
                  (translatable "yes")) Clamp)))

(define %stack-page-2
  `(object (@ (class "GtkStackPage"))
     (property (@ (name "title")
                  (translatable "yes")) Spring)
     (property (@ (name "name")) Spring)
     (property (@ (name "child"))
       (object (@ (class "AdwPreferencesGroup"))
         (child ,%sa-velocity)
         (child ,%sa-damping)
         (child ,%sa-mass)
         (child ,%sa-stiffness)
         (child ,%sa-epsilon)
         (child ,%sa-clamp-switch)))))

(define %animations-page
  `(interface
    (requires (@ (version "4.0") (lib "gtk")))
    (requires (@ (version "1.0") (lib "libadwaita")))
    (template (@ (class "AdwDemoPageAnimations")
                 (parent "AdwBin"))
      (property (@ (name "child"))
        (object (@ (class "AdwToolbarView"))
          (child (@ (type "top"))
            (object (@ (class "AdwHeaderBar"))
              (property (@ (name "show-title")) False)))
          (property (@ (name "content"))
            (object (@ (class "GtkScrolledWindow"))
              (property (@ (name "hscrollbar-policy")) never)
              (property (@ (name "child"))
                (object (@ (class "GtkBox"))
                  (property (@ (name "orientation")) vertical)
                  (property (@ (name "valign")) center)
                  (style (class (@ (name "animation-page"))))
                  (child
                      (object (@ (class "GtkBox"))
                        (property (@ (name "orientation")) vertical)
                        (child ,%animation-clamp)
                        (child ,%label-1)
                        (child ,%label-2)))
                  (child
                      (object (@ (class "GtkBox")
                                 (id "animation-bt-box"))
                        (property (@ (name "valign")) center)
                        (property (@ (name "halign")) center)
                        (property (@ (name "margin-top")) 30)
                        (property (@ (name "margin-bottom")) 30)
                        (property (@ (name "spacing")) 18)
                        (child ,%skip-backward-bt)
                        (child ,%play-pause-bt)
                        (child ,%skip-forward-bt)))
                  (child
                      (object (@ (class "AdwPreferencesGroup"))
                        (child ,%stack-switcher)))
                  (child
                      (object (@ (class "AdwClamp"))
                        (property (@ (name "maximum-size")) 400)
                        (property (@ (name "tightening-threshold")) 300)
                        (property (@ (name "child"))
                          (object (@ (class "GtkStack")
                                     (id "animation-prefs-stack"))
                            ;; signal
                            ;;   notify::visible-child-name
                            ;;   timed-animation-reset
                            ;;   swapped
                            (child ,%stack-page-1)
                            (child ,%stack-page-2))))))))))))))


(define (make-ui)
  (sxml->ui %animations-page))
