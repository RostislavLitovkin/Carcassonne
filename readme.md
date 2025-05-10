# AFP Semestral work - Carcassonne web game

A multiplayer web version of popular board game Carcassonne.

Focus is on functionality and playability.

## Project structure

- REST server to handle multiplayer
- Elm website as Frontend

## Carcassonne overview

Carcassonne is a tile-placement board game designed by Klaus-Jürgen Wrede and first published in 2000. Named after the medieval fortified town of Carcassonne in southern France, the game involves players drawing and placing tiles to build cities, roads, cloisters, and fields. Each tile must connect properly to existing tiles, creating a growing map.

Players can place "meeples" (small wooden figures) on features to claim them for points. Scoring occurs when features are completed or at the end of the game for incomplete features and fields.

### Expansions

Carcassonne also has countless of expansions, like:

- Inns & Cathedrals
- Traders & Builders
- The Princess & the Dragon
- The Tower (I hate this one :D)
- Bridges, Castles & Bazaars
...

For the limited time reasons, I will not be including any expansions.

## Carcassonne rules

### Objective

Score the most points by completing and claiming cities, roads, cloisters, and fields using tiles and meeples.

### Setup

1 starting tile is in the center of the playable grid.

Rest of the tiles are shuffled randomly and placed in a draw stack.

Each player gets 6 meeples + 1 meeple that goes on the score track

Choose a starting player.

### Gameplay

Carcassonne is a turn-based game. 

Each turn, players do these 3 steps:

1) Draw 1 tile and place it on the board. If it can not be placed, shuffle it back and draw a new one.
2) Optionally place a maybe on the tile that the player just placed. The meeple can be placed on the city, road, cloister and field.
3) If a city, road or a cloister have been finished, count the points immediately.

### Point counting

The player that has the most meeples on the completed feature gets the points.

If there are multiple players with the same amount of meeples on the feature, they both get the same amount of points.

- Completed Road is worth 1 points per each tile.
- Completed City is worth 2 points per each tile.
- Completed Cloister is worth 9 points in total. Cloister is completed when all of the adjacent tiles are filled.

At the end of the game, once all of the tiles have been drawn, you count the rest of the points:

- Incomplete Road is worth 1 point per each tile.
- Incomplete City is worth 1 points per each tile.
- Incomplete Cloister is worth 1 for adjacent tile + 1 point for itself.
- Field is worth 3 points for each complete city that is touching the field.

### Advices from other players

Players need to show their tile that they have drawn to all other players so that they can give them "good advice".

It is my favourite rule that will make the game just a bit more interesting!

# Carcassonne server

## Build and run

**TODO**

## Specification

### Player

Just identified by string name

### Feature

City/Road/Field

### Tile

Has ID for Texture to use for rendering + Rotation 0/90/180/270

Has 4 sides, each identified by unique ID used for tracking which features are connected together + Feature enum

And in the middle there can be a Cloister -> true/false

### Game State

- PlaceTile - Player on turn must place a tile
- PlaceMeeple - Player may place a meeple on the tile played
- Finished - There are no more tiles to be placed. Score is counted and winner is determined

## REST API Specification

### POST - Setup

Sets up a new game

If a game was being played, it overwrites it

Parameters:
- List of Player names

### GET - game

Returns null if a game does not exist.

Gets the info about an ongoing game, like:

- List of all players, and their score
- Player that is on turn
- Tile to be placed
- Game State 
- Tile last played
- Number of tiles remaining in the draw stack
- grid with tiles
- grid with meeples

### POST - place_tile

Place a tile

Parameters:
- x coordinate
- y coordinate

### POST - place_meeple

Place a meeple on the tile just played.

Parameters:
- feature id
- field id

If both feature id and field id are null, skip placing the meeple.

Only 1 meeple can be placed at once. Otherwise 400 is returned

## Techstack used

**TODO**

# Carcassonne web UI

## Build and run

**TODO**

## Techstack used

**TODO**

# Original game 

- Official website: https://cundco.de/en/