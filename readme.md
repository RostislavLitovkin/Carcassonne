# AFP Semestral work - Carcassonne web game

A multiplayer web version of popular board game Carcassonne built using Lamdera.

Focus is on functionality and playability.

## Try it out!

- https://carcassonne.lamdera.app/

![image](https://github.com/user-attachments/assets/3a7cd8c3-7134-4abf-bb94-b5e4b21b9de1)

## Project structure

- Lamdera takes care of both frontend and backend code.

![lamdera-architecture](https://github.com/user-attachments/assets/51f262ec-e4f8-4b68-8257-c5b55fcc4844)

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

## Specification

### Player

Just identified by string name

### Feature

City/Road/Field

### Tile

Has TileId used for finding the Texture to use for rendering + Rotation 0/90/180/270...

Has 4 sides, each identified by unique SideId used for tracking which features are connected together + Feature enum

And in the middle there can be a Cloister -> Just SideId / Nothing

### Meeple

A figure placed on a coordinate, identified by SideId they are occupying. More than 1 meeple may occupy the SideId.

It also contains a position that determines where on the tile the meeple is placed - mostly important for rendering.

Lastly, it holds the owner's PlayerIndex. 

### Game State

- PlaceTile - Player on turn must place a tile
- PlaceMeeple - Player may place a meeple on the tile played
- Finished - There are no more tiles to be placed. Score is counted and winner is determined

### Player registration & Lobby

A lobby system has been also implemented. It allows the user to enter their name and join a lobby, kick players from lobby...

If somebody got disconnected, they can re-enter their name and they can continue playing.

### Debug mode

A special debug mode has been implemented to display the individual SideIds of each tile.

Keep in mind that you can not place tiles/meeples when debug mode is turned on.

![image](https://github.com/user-attachments/assets/6add31b5-2933-4689-96a3-b5ffad548aa1)

## Build and run

```
lamdera live
```

## Deploy to lamdera

Add lamdera git remote:

```
git remote add lamdera git@apps.lamdera.com:carcassonne.git
```

If you push to lamdera remote, the app will get automatically deployed and updated:

```
git push lamdera
```

## Unit tests

Found in `tests` folder.

```
npx elm-test --compiler lamdera
```

## Techstack used

- Elm
- Lamdera
- Elm-community packages
- elm-exploration/test

# Original game 

- Official website: https://cundco.de/en/
