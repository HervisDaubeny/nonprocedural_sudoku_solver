# **Dokumentace k programu sudoku.hs**

## Zadání
Mým úkolem bylo napsat v Haskellu program na řešení sudoku, implementující dva řešící algoritmy. Úkol jsem si rozšířil o komunikaci s uživatelem pomocí funkce ``main```

## Spouštění programu
Před spuštěním je potřeba program nejprve zkompilovat pomocí haskellovského interpreteru. To provedeme příkazem
```sh
ghc --make -dynamic sudoku.hs
```
*předpokládám naistalovaný interpreter* ```ghci```

## Uživatelské rozhraní
Jelikož se vlastně jedná o program žijící v konzoli, je *rozhraní* pojato velmi minimalisticky. Na začátku je uživatel požádán aby řádek po řádku vyplnil zadání sudoku, načež se jej program pokusí vyřešit a na konci dá výstup.
1) vypíše vyřešené sudoku s hláškou s významem "je to vyřešené"
2) vypíše hlášku s významem "nezvládl jsem to" a aktuální stav řešení

### příklad:
```sh
> ./sudoku
Input a sudoku line by line, as arrays of ints, with empty cell represented by zero.
[0,0,6,5,9,4,7,0,0]
[8,0,9,0,6,0,2,0,4]
[1,0,0,0,0,0,0,0,3]
[0,0,0,0,5,0,0,0,0]
[0,0,3,7,4,8,6,0,0]
[5,9,0,0,0,0,0,4,2]
[0,3,1,0,0,0,5,2,0]
[7,6,0,0,0,0,0,1,9]
[0,0,0,8,0,3,0,0,0]

# output of the program will follow here
```

## Hlavní datová struktura
V celém programu se setkáváme s datovou strukturou ```Cell```, která je implementovaná následovně
```hs
data Cell = Cell Int [Int] deriving (Show, Eq)
-- Cell value::Int possibilities::[Int]
-- Show for printing result
-- Eq for comparing instances of sudoku. (used to stop the solving cycle)
```

## O algoritmech

### single possibility in cell algorithm
Tento algoritmus postupně projde celé sudoku a v každé buňce spočítá zbývající možnosti. Pokud zbývá právě jedna, je vyplněna jako hodnota buňky a pole možností se vyprázdní.
Algoritmus se sestává z funkcí:
```single_cell_poss``` ```traverse_line``` ```cell_fill_single```
Přičemž ```single_cell_poss``` dostane na vstupu celé sudoku a vrací pole tripletů (řádek, sloupec, hodnota), které použije funkce ```sweeper```, ke které se dostaneme. ```traverse_line``` je pomocná funkce, která zmenší problém z celého sudoku na jednotlivé řádky a ```cell_fill_single``` na jednotlivé buňky.

### single possibility in line algorithm
Algoritmus využívá podobnou myšlenku jako předchozí, ale narozdíl od něj pracuje nad celými řádky, místo jedontlivými buňkami.
Algoritmus si nejprve přes všechny buňky na řádce spočítá, kolikrát se vyskytují jednotlivé možnosti. Pokud zjistí, že se některá možnost vyskytuje právě jendou, doplní ji.
Algoritmus se sestává z funkcí ```single_line_poss``` ```count_line``` ```count_cell``` ```get_single``` ```line_fill_single```. Kde ```single_line_poss``` sdružuje následující pomocné fce: ```count_line``` použije ```count_cell``` a získá všechny možnosti v tuplu se sloupcem kde se se nachází. ```get_single``` vybere ty tuply, které reprezentují jedinou možnost v rámci řádku a ```line_fill_single``` tyto možnosti doplní a vrátí, nám už známé, pole tripletů pri sweepovací algoritmus.

### sweeping algorithm
Zmiňovaný sweeper se používá v kombinaci s haskellovskou funkcí ```iterate```, která zařídí opakování v cyklu, dokud *je co sweepovat*.
Co to *sweepování* je? Používáme pro něj triplet ```(row, column, value)``` následovně. V řádku odpovídající hodnotě v ```row``` z každé buňky odstraníme z pole ```possibilities``` předanou ```value```. Potom sudoku transponujeme a to stejné uděláme se sloupci a hodnouto ```column```. Nakonec sudoku přetransformujeme tak, že související devítice se uloží do jednoho řádku, přepočítáme hodnoty ```row``` a ```column``` aby i-tý blok odpovídal i-tému řádku a opět *sweepneme*.

### transformations
Nejedná se přímo o konkrétní algoritmus, ale spíš o využití myšlenky. ```single_line_poss``` je jak název napovídá algoritmus, který pracuje nad řádky. Zajímavé na tom je, že když dokážu přetransformovat sudoku jak ho mám (tedy řádek reprezentuje řádek) tak, aby byl řádkem reprezentovaný sloupec nebo dokonce blok devíti buněk, mohu na využít ```single_line_poss``` a pak jen vrátit data sudoku do standartní reprezentace.
O to se mi starají funkce ```get_columns_from_lines``` ```get_lines_from_columns``` (což je v podstatě jen volání fce ```transpose```) a ```get_blocks_from_lines``` ```get_lines_from_blocks```, kde už je potřeba přepočítávat souřadnice.

## Běh programu
Jak progrma využívá své jednotlivé části si popíšeme pseudokódem.
```hs
1) načti vstup
2) převeď zadaná data do [[Cell]] a veškreré vyplněné hodnoty sweepni
3) spusť řešící cyklus:
    -- na hodnoty předané v sudoku
    single_cell_poss -> sweep
    single_line_poss -> sweep
    transform to columns -> single_line_poss -> transform back -> sweep
    transform to blocks -> single_line_poss -> transform back -> sweep
    -- v novéSudoku je uložený výsledek výše uvedených kroků

    if (sudoku == novéSudoku)
      -> skonči
    else
      -> proveď další iteraci cyklu

4) check_if_solved
5) print result
```
Tuto konstrukci umožnuje ```deriving Eq``` v definici struktury. Mohu díky tomu jednoduše porovnat *starou* a *novou* instanci ```[[Cell]]``` a pokud nedošlo k jediné změně vím, že můj program už nemá co by doplnil a to ať už proto že je sudoku vyřešené nebo příliš těžké.

## Závěr
Na tomto projektu jsem si vyzkoušel napsat neprocedurální řešič sudoku a objevil tak trochu jiný způsob jeho řešení. Narozdíl od precedurálního řešiče, který jsem psal před lety, nebylo v této implementaci jednoduché vytvářet cykly a algoritmy, které sudoku počítají. Díky tomu jsem se poprvé zamyslel nad variantou transformování sudoku a využívání již existujícího algoritmu, raději než tvorbu nových algoritmů pro sloupce a bloky.
