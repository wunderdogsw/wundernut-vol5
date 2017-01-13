(ns wunderdraw.core
  "Solves a secret message from image according to
   instructions from https://github.com/wunderdogsw/wunderpahkina-vol5.
   Requires a dependency [net.mikera/imagez \"0.12.0\"]"

  (:require [mikera.image.core :as image]
            [mikera.image.colours :as colours]
            [clojure.java.io :refer [resource]]))

(def up [7 84 19 255])
(def left [139 57 137 255])
(def stop [51 69 169 255])
(def right-turn [182 149 72 255])
(def left-turn [123 131 154 255])

(defn move [direction i]
  (case direction
    :up    (- i 180)
    :down  (+ i 180)
    :left  (dec i)
    :right (inc i)))

(defn turn [direction ctrl]
  (case [direction ctrl]
    [:up :turn-left]     :left
    [:up :turn-right]    :right
    [:down :turn-left]   :right
    [:down :turn-right]  :left
    [:left :turn-left]   :down
    [:left :turn-right]  :up
    [:right :turn-left]  :up
    [:right :turn-right] :down))

(defn find-path [path idx direction controls]
  (let [p             (conj path idx)
        ctrl          (controls idx)
        new-direction (if (or (= ctrl :stop) (nil? ctrl))
                        direction
                        (turn direction ctrl))]
    (if (= ctrl :stop)
      p
      (recur p (move new-direction idx) new-direction controls))))

(defn start-point [idx pxl]
  (let [argb (colours/components-argb pxl)]
    (cond
      (= argb up)   [idx :up]
      (= argb left) [idx :left])))

(defn ctrl-point [idx pxl]
  (let [argb (colours/components-argb pxl)]
    (cond
      (= argb left-turn)  [idx :turn-left]
      (= argb right-turn) [idx :turn-right]
      (= argb stop)       [idx :stop])))

(defn draw-message [img-path]
  (let [img      (-> img-path resource image/load-image)
        pixels   (-> img image/get-pixels vec)
        starts   (keep-indexed start-point pixels)
        controls (into {} (keep-indexed ctrl-point pixels))
        path     (mapcat
                  (fn [[idx direction]]
                    (find-path [] idx direction controls))
                  starts)
        canvas   (int-array (repeat (* 180 60) (.intValue colours/black)))]

    (doseq [i path]
      (aset canvas i (.intValue colours/red)))

    (image/set-pixels img canvas)
    (image/show img)))

(draw-message "3663c24c-c5db-11e6-8be5-e358d0e0215a.png")
