(ns pahkina5.core
  (:require [mikera.image.core :as image]))

(def pixel->instruction {0xff075413 :start-up
                         0xff8b3989 :start-left
                         0xff3345a9 :stop
                         0xffb69548 :turn-right
                         0xff7b839a :turn-left})

(defn load-image [resource-name]
  (let [img (image/load-image-resource resource-name)]
    {:width          (image/width img)
     :height         (image/height img)
     :instruction-at (fn [[x y]] (pixel->instruction (image/get-pixel img x y)))}))

(defn move [{:keys [direction] :as state}]
  (update state :position (partial mapv +) direction))

(defn turn-left [[x y]]
  [y (- x)])

(defn turn-right [[x y]]
  [(- y) x])

(defn path [instruction-at starting-state]
  (loop [current-path []
         {:keys [position] :as state} starting-state]
    (let [current-path (conj current-path position)
          instruction (instruction-at position)
          turned-state (case instruction
                         :turn-right (update state :direction turn-right)
                         :turn-left (update state :direction turn-left)
                         state)]
      (if (= :stop instruction)
        current-path
        (recur current-path (move turned-state))))))

(defn starting-states [{:keys [width height instruction-at]}]
  (for [x (range width)
        y (range height)
        :let [instruction (instruction-at [x y])]
        :when (#{:start-up :start-left} instruction)]
    {:position  [x y]
     :direction (case instruction
                  :start-up [0 -1]
                  :start-left [-1 0])}))

(defn colored-pixels [img]
  (mapcat (partial path (:instruction-at img)) (starting-states img)))

(defn draw-image [width height pixels]
  (let [img (image/new-image width height false)]
    (doseq [[x y] pixels]
      (image/set-pixel img x y 0xFF0000))
    img))

(defn solve-problem [input-resource output-filename]
  (let [input-img (load-image input-resource)
        output-img (draw-image (:width input-img) (:height input-img) (colored-pixels input-img))]
    (image/save output-img output-filename)))

(defn -main []
  (println "Generating output.png from resources/secret_message.png")
  (solve-problem "secret_message.png" "output.png"))
