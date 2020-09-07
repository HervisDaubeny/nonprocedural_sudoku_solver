-- imports
import Data.List
import Control.Monad


-- type definitions
data Cell = Cell Int [Int] deriving (Eq, Show)


-- sample data
s = [[0,0,6,5,9,4,7,0,0],[8,0,9,0,6,0,2,0,4],[1,0,0,0,0,0,0,0,3],[0,0,0,0,5,0,0,0,0],[0,0,3,7,4,8,6,0,0],[5,9,0,0,0,0,0,4,2],[0,3,1,0,0,0,5,2,0],[7,6,0,0,0,0,0,1,9],[0,0,0,8,0,3,0,0,0]]

-- custom redefinitions
takeWhileOneMore :: (a -> Bool) -> [a] -> [a]
takeWhileOneMore p = foldr (\x ys -> if p x then x:ys else [x]) []

condTake :: Eq t => [t] -> [t]
condTake list
  | length list == 0 = []
  | length list == 1 = list
condTake (fst:rem@(snd:rem2))
  | fst /= snd = [fst] ++ (condTake rem)
  | fst == snd = [fst]


-- transformation alorithms
get_columns_from_lines :: [[Cell]] -> [[Cell]]
get_columns_from_lines sudoku = (transpose sudoku)

get_lines_from_columns :: [[Cell]] -> [[Cell]]
get_lines_from_columns cols = (transpose cols)

get_blocks_from_lines :: [[Cell]] -> [[Cell]]
get_blocks_from_lines sudoku = blocks_as_lines
  where blocks_as_lines = [b0] ++ [b1] ++ [b2] ++ [b3] ++ [b4] ++ [b5] ++ [b6] ++ [b7] ++ [b8]
        b0 = (take 3 (sudoku !! 0)) ++ (take 3 (sudoku !! 1)) ++ (take 3 (sudoku !! 2))
        b1 = (take 3 (drop 3 (sudoku !! 0))) ++ (take 3 (drop 3 (sudoku !! 1))) ++ (take 3 (drop 3 (sudoku !! 2)))
        b2 = (take 3 (drop 6 (sudoku !! 0))) ++ (take 3 (drop 6 (sudoku !! 1))) ++ (take 3 (drop 6 (sudoku !! 2)))

        b3 = (take 3 (sudoku !! 3)) ++ (take 3 (sudoku !! 4)) ++ (take 3 (sudoku !! 5))
        b4 = (take 3 (drop 3 (sudoku !! 3))) ++ (take 3 (drop 3 (sudoku !! 4))) ++ (take 3 (drop 3 (sudoku !! 5)))
        b5 = (take 3 (drop 6 (sudoku !! 3))) ++ (take 3 (drop 6 (sudoku !! 4))) ++ (take 3 (drop 6 (sudoku !! 5)))

        b6 = (take 3 (sudoku !! 6)) ++ (take 3 (sudoku !! 7)) ++ (take 3 (sudoku !! 8))
        b7 = (take 3 (drop 3 (sudoku !! 6))) ++ (take 3 (drop 3 (sudoku !! 7))) ++ (take 3 (drop 3 (sudoku !! 8)))
        b8 = (take 3 (drop 6 (sudoku !! 6))) ++ (take 3 (drop 6 (sudoku !! 7))) ++ (take 3 (drop 6 (sudoku !! 8)))

get_lines_from_blocks :: [[Cell]] -> [[Cell]]
get_lines_from_blocks blocks = sudoku
  where sudoku = [l0] ++ [l1] ++ [l2] ++ [l3] ++ [l4] ++ [l5] ++ [l6] ++ [l7] ++ [l8]
        l0 = (take 3 (blocks !! 0)) ++ (take 3 (blocks !! 1)) ++ (take 3 (blocks !! 2))
        l1 = (take 3 (drop 3 (blocks !! 0))) ++ (take 3 (drop 3 (blocks !! 1))) ++ (take 3 (drop 3 (blocks !! 2)))
        l2 = (take 3 (drop 6 (blocks !! 0))) ++ (take 3 (drop 6 (blocks !! 1))) ++ (take 3 (drop 6 (blocks !! 2)))

        l3 = (take 3 (blocks !! 3)) ++ (take 3 (blocks !! 4)) ++ (take 3 (blocks !! 5))
        l4 = (take 3 (drop 3 (blocks !! 3))) ++ (take 3 (drop 3 (blocks !! 4))) ++ (take 3 (drop 3 (blocks !! 5)))
        l5 = (take 3 (drop 6 (blocks !! 3))) ++ (take 3 (drop 6 (blocks !! 4))) ++ (take 3 (drop 6 (blocks !! 5)))

        l6 = (take 3 (blocks !! 6)) ++ (take 3 (blocks !! 7)) ++ (take 3 (blocks !! 8))
        l7 = (take 3 (drop 3 (blocks !! 6))) ++ (take 3 (drop 3 (blocks !! 7))) ++ (take 3 (drop 3 (blocks !! 8)))
        l8 = (take 3 (drop 6 (blocks !! 6))) ++ (take 3 (drop 6 (blocks !! 7))) ++ (take 3 (drop 6 (blocks !! 8)))


-- solving_algorithms
---- single possibility in cell algorithm
single_cell_poss :: [[Cell]] -> ([(Int, Int, Int)], [[Cell]])
single_cell_poss sudoku = (toSweep, newSudoku)
  where (newSudoku, sweepPacked) = unzip (map traverse_line (zip sudoku [0..8]))
        toSweep = concat(sweepPacked)

traverse_line :: ([Cell], Int) -> ([Cell], [(Int, Int, Int)])
traverse_line (line, rn) = result
  where tmp = (map cell_fill_single (zipWith4 (,,,) line [rn, rn..] [0..8] [0,0..]))
        (newLine, coords) = (unzip tmp)
        filtered = dropWhile (\(_, _, a) -> a < 1) (sortBy (\(_, _, a) (_, _, b) -> (compare a b)) coords)
        result = (newLine, filtered)

cell_fill_single :: (Cell, Int, Int, Int) -> (Cell, (Int, Int, Int))
cell_fill_single ((Cell val poss), row, column, filled)
  | length(poss) == 1 && val == 0 = ((Cell (head(poss)) []), (row, column, head(poss)))
  | otherwise = ((Cell val poss), (row, column, filled))

---- single possibility in line algorithm
single_line_poss :: [[Cell]] -> ([(Int, Int, Int)], [[Cell]])
single_line_poss sudoku = (toSweep, newSudoku)
  where (sweepPacked, newSudoku) = unzip (map count_line (zip sudoku [0..8]))
        toSweep = concat(sweepPacked)

count_line :: ([Cell], Int) -> ([(Int, Int, Int)], [Cell])
count_line (line, rn) = (toSweep, newLine)
  where possibilities = concat (map count_cell (zip line [0..8]))
        sorted = (sortBy (\(x, _) (y, _) -> (compare x y)) possibilities)
        grouped = (groupBy (\(x, _) (y, _) -> (x == y)) sorted)
        single = (dropWhile (\(x, _) -> x < 1) (sortBy (\(x, _) (y, _) -> (compare x y)) (map get_single grouped)))
        (_, newLine) = last (takeWhileOneMore (\(toFill, _) -> (length toFill) > 0) (iterate line_fill_single (single, line)))
        (values, columns) = unzip single
        toSweep = (zipWith3 (,,) [rn,rn..] columns values)

get_single :: [(Int, Int)] -> (Int, Int)
get_single array
  | length array == 1 = (head array)
  | otherwise = (0, 0)

line_fill_single :: ([(Int, Int)], [Cell]) -> ([(Int, Int)], [Cell])
line_fill_single (((newVal, target):toFill), oldLine) = (toFill, newLine)
  where newLine = map fill (zip oldLine [0..8])
        fill ((Cell val poss), column)
          | column == target = (Cell newVal [])
          | otherwise = (Cell val poss)

count_cell :: (Cell, Int) -> [(Int, Int)]
count_cell ((Cell val poss), cn) = result
  where result = map (\x -> (x, cn)) poss

-- sweeping algorithm

sweep_line :: (Int, Int, Int) -> [[Cell]] -> [[Cell]]
sweep_line (row, _, val) table = newTable
  where newTable = map decide_line (zip table [0..8])
        decide_line (line, num)
          | num == row = map removeWithParam line
          | otherwise = line
        removeWithParam = remove_poss val

sweep_column :: (Int, Int, Int) -> [[Cell]] -> [[Cell]]
sweep_column (_, col, val) table = newTable
  where newTable = map decide_column (zip table [0..8])
        decide_column (column, num)
          | num == col = map removeWithParam column
          | otherwise = column
        removeWithParam = remove_poss val

sweep_block :: (Int, Int, Int) -> [[Cell]] -> [[Cell]]
sweep_block (row, col, val) table = newTable
  where newTable = map decide_block (zip table [0..8])
        decide_block (block, num)
          | num == (block_num row col) = map removeWithParam block
          | otherwise = block
        block_num rn cn
          | rn < 3 && cn < 3 = 0
          | rn < 3 && cn < 6 = 1
          | rn < 3 && cn < 9 = 2
          | rn < 6 && cn < 3 = 3
          | rn < 6 && cn < 6 = 4
          | rn < 6 && cn < 9 = 5
          | rn < 9 && cn < 3 = 6
          | rn < 9 && cn < 6 = 7
          | rn < 9 && cn < 9 = 8
        removeWithParam = remove_poss val

remove_poss :: Int -> Cell -> Cell
remove_poss remove (Cell value poss) = (Cell value newPoss)
  where fstPoss = (takeWhile (/= remove) poss)
        sndPoss = (drop (length(fstPoss) + 1) poss)
        newPoss = fstPoss ++ sndPoss

sweeper :: ([(Int, Int, Int)], [[Cell]]) -> ([(Int, Int, Int)], [[Cell]])
sweeper (coords, sudoku) = (new_coords, new_sudoku)
  where tmp1 = (sweep_line (head coords) sudoku)
        tmp2 = transpose (sweep_column (head coords) (transpose tmp1))
        tmp3 = get_lines_from_blocks (sweep_block (head coords) (get_blocks_from_lines tmp2))
        new_coords = (drop 1 coords)
        new_sudoku = tmp3


-- input processing
parse_lines :: [[Char]] -> [Int]
parse_lines l1nes = (map (read::[Char]->Int) l1nes)

set_data :: [[Int]] -> ([(Int, Int, Int)], [[Cell]])
set_data input = (toSweep, sudoku)
  where result = map set_line (zip input [0..8])
        set_line (line, rn) = unzip (map set_cell (zipWith3 (,,) line [rn, rn..] [0..8]))
        (sudoku, sweepPacked) = unzip result
        sweepUnpacked = concat(sweepPacked)
        toSweep = dropWhile (\(_, _, a) -> a < 1) (sortBy (\(_, _, a) (_, _, b) -> (compare a b)) sweepUnpacked)

set_cell :: (Int, Int, Int) -> (Cell, (Int, Int, Int))
set_cell (value, row, column)
  | value == 0 = ((Cell 0 [1,2,3,4,5,6,7,8,9]), (0,0,0))
  | otherwise = ((Cell value [1,2,3,4,5,6,7,8,9]), (row, column, value))

-- solving cycle
solve :: [[Int]] -> [[Cell]]
solve input = solvedSudoku
  where (toSweep, sudoku) = (set_data input)
        initializedSudoku = snd (last (takeWhileOneMore nonempty_coords (iterate sweeper (toSweep, sudoku))))
        solvedSudoku = snd(last (takeWhile (\(continue, _) -> continue == False) (iterate full_cycle (False, initializedSudoku))))

full_cycle :: (Bool, [[Cell]]) -> (Bool, [[Cell]])
full_cycle (_, sudoku) = (continue, newSudoku)
  where (swp1, sud1) = single_cell_poss sudoku
        res1 = snd (last (takeWhileOneMore nonempty_coords (iterate sweeper (swp1, sud1))))
        (swp2, sud2) = single_line_poss res1
        res2 = snd (last (takeWhileOneMore nonempty_coords (iterate sweeper (swp2, sud2))))
        (colSwp, colSud) = single_line_poss (get_columns_from_lines res2)
        swp3 = map (\(col, row, val) -> (row, col, val)) colSwp
        sud3 = get_lines_from_columns colSud
        res3 = snd (last (takeWhileOneMore nonempty_coords (iterate sweeper (swp3, sud3))))
        (blSwp, blSud) = single_line_poss (get_blocks_from_lines res3)
        swp4 = map translate_block_coords blSwp
        sud4 = get_lines_from_blocks blSud
        newSudoku = snd (last (takeWhileOneMore nonempty_coords (iterate sweeper (swp4, sud4))))
        continue = sudoku == newSudoku

translate_block_coords :: (Int, Int, Int) -> (Int, Int, Int)
translate_block_coords (block, loc, val) = (row, col, val)
  where row = ((div block 3) * 3 + (div loc 3))
        col = ((mod block 3) * 3 + (mod loc 3))

nonempty_coords :: ([(Int, Int, Int)], [[Cell]]) -> Bool
nonempty_coords (coords, _) = (length coords) > 0

-- result state
check_if_solved :: [[Cell]] -> Bool
check_if_solved sudoku = sum([1,2,3,4,5,6,7,8,9]) * 9 == sum(map sum_line sudoku)

sum_line :: [Cell] -> Int
sum_line line = sum (map get_value line)

get_value :: Cell -> Int
get_value (Cell value _) = value

-- extract result
get_values :: [Cell] -> [Int]
get_values line = (map get_value line)


-- entry point
main = do
  putStrLn "Input a sudoku line by line, as arrays of ints, with empty cell represented by zero."
  l1nes <- replicateM 9 getLine
  let input = (map (read::String->[Int]) l1nes)
  let result = solve input
  let solved = check_if_solved result
  if solved == True
    then do
        putStr "\n"
        print "I've got this!"
        mapM_ print (map get_values result)
    else do
        putStr "\n"
        print "That was too hard for me. I got to this tho:"
        mapM_ print result
