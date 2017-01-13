module Lib
    ( crunchInputToOutput
    ) where

import qualified Data.Map.Strict as M

import Codec.Picture (generateImage, readImage, writeGifAnimation)
import Codec.Picture.Gif (GifLooping(LoopingForever))
import Codec.Picture.Types (pixelAt, PixelRGB8(..), Image(..), DynamicImage(ImageRGB8))
import Control.Applicative (liftA2)
import Data.Maybe (catMaybes)

data Point = Point { x :: Int, y :: Int } deriving (Show, Ord, Eq)

data Direction = UP | RIGHT | DOWN | LEFT deriving (Enum, Bounded, Show)

turnLeft :: Direction -> Direction
turnLeft UP = LEFT
turnLeft dir = pred dir

turnRight :: Direction -> Direction
turnRight LEFT = UP
turnRight dir = succ dir

data Step = Step {point :: Point, direction :: Direction, done :: Bool } deriving Show

data Action = TURN_LEFT | TURN_RIGHT | STOP deriving Show

type Actions = M.Map Point Action
type Steps = [Step]

data DrawColor = Black | Red

type PlotFrame = M.Map Point DrawColor

----------------------------
-- Start up   7, 84, 19
-- Start left 139, 57, 137
-- Stop       51, 69, 169
-- Turn right 182, 149, 72
-- Turn left  123, 131, 154
----------------------------
pixelToDirectionOrAction :: PixelRGB8 -> Maybe (Either Direction Action)
pixelToDirectionOrAction (PixelRGB8 r g b) = case (r, g, b) of
                                         (7, 84, 19)     -> Just $ Left UP
                                         (139, 57, 137)  -> Just $ Left LEFT
                                         (51, 69, 169)   -> Just $ Right STOP
                                         (182, 149, 72)  -> Just $ Right TURN_RIGHT
                                         (123, 131, 154) -> Just $ Right TURN_LEFT
                                         _               -> Nothing

getDirection :: Maybe Action -> Point -> Direction -> Direction
getDirection maybeAction p d = case (d, maybeAction) of
                                 (direction, Just TURN_LEFT)  -> turnLeft direction
                                 (direction, Just TURN_RIGHT) -> turnRight direction
                                 (direction, _)               -> direction

nextStep :: Actions -> Step -> Maybe Step
nextStep actions (Step curPoint@(Point x y) currentDirection done) =
  case (maybeAction, done) of
    (_, True)          -> Nothing
    (Just STOP, False) -> Just (Step nextPoint newDirection True)
    (_, False)         -> Just (Step nextPoint newDirection False)
   where maybeAction = M.lookup nextPoint actions
         newDirection = getDirection maybeAction nextPoint currentDirection
         nextPoint = case currentDirection of
                      UP -> Point x (y - 1)
                      RIGHT -> Point (x + 1) y
                      DOWN -> Point x (y + 1)
                      LEFT -> Point (x - 1) y

parseInput :: FilePath -> IO ((Steps, Actions), Int, Int)
parseInput fp = do
  image <- readImage fp
  case image of
    Left _ -> return (([], M.empty), 0, 0)
    Right image' -> return (analyseInput image')
  where
    analyseInput (ImageRGB8 image@(Image w h _)) = (foldl (coordinateToData image) ([], M.empty) coordinates, w, h)
      where coordinates = liftA2 Point [0..(w - 1)] [0..(h - 1)]

coordinateToData :: Image PixelRGB8 -> (Steps, Actions) -> Point -> (Steps, Actions)
coordinateToData inputImage acc@(steps, actions) point@(Point x y) =
  case directionOrAction of
    Nothing -> acc
    Just (Left direction) -> (Step point direction False : steps, actions)
    Just (Right action) -> (steps, M.insert point action actions)
  where directionOrAction = pixelToDirectionOrAction pixel
        pixel = pixelAt inputImage x y

stepsAndActionsIntoGifFrames :: (Steps, Actions) -> Int -> Int -> [Image PixelRGB8]
stepsAndActionsIntoGifFrames (steps, actions) w h = foldToImages w h [plotFrameToImage w h allBlack] allBlack actions (reverse steps)
  where allBlack = M.fromList $ zip (liftA2 Point [0..(w - 1)] [0..(h - 1)]) (repeat Black)

foldToImages :: Int -> Int -> [Image PixelRGB8] -> PlotFrame -> Actions -> Steps -> [Image PixelRGB8]
-- Commented version: Draw every line at the same time. If you use this change GifDelay to 5 in crunchInputToOutput.
--foldToImages w h acc _ _ [] = reverse acc ++ replicate 20 (head acc)
--foldToImages w h acc prevFrame actions steps = foldToImages w h (plotFrameToImage w h curFrame : acc) curFrame actions nextSteps
--  where curFrame = M.union (foldl (\acc (Step point _ _) -> M.insert point Red acc) M.empty steps) prevFrame
--        nextSteps = catMaybes (map (nextStep actions) steps)
foldToImages w h acc _ _ [] = reverse acc ++ replicate 100 (head acc)
foldToImages w h acc prevFrame actions (step@(Step point _ _):steps) = foldToImages w h (plotFrameToImage w h curFrame : acc) curFrame actions nextSteps
  where curFrame = M.insert point Red prevFrame
        nextSteps = case nextStep actions step of
                      Just next -> next : steps
                      Nothing -> steps


plotFrameToImage :: Int -> Int -> PlotFrame -> Image PixelRGB8
plotFrameToImage w h plot = generateImage (\x y -> case M.lookup (Point x y) plot of
                                                     Just Black -> PixelRGB8 0 0 0
                                                     Just Red -> PixelRGB8 255 0 0)
                                          w h

crunchInputToOutput :: IO ()
crunchInputToOutput = do
  putStrLn "Processing..."
  (stepsAndActions, w, h) <- parseInput "secret_message.png"
  let images = stepsAndActionsIntoGifFrames stepsAndActions w h
  let writeResult = writeGifAnimation "result.gif" 2 LoopingForever images
  case writeResult of
    Left msg -> putStrLn msg
    Right writeImageToDisk -> do
      writeImageToDisk
      putStrLn "Result written!"
