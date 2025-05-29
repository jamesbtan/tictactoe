# Todo
- [x] Implement game logic
- [x] Create front-end for interactive play
- [x] Implement MCTS logic

# Log
## 2025-05-29
- theoretically it works?
- can tie all games, and reliably punishes bad play
- I had to increase the depth quite a bit though
- e.g. 1000 loses when it goes second, but 10000 is enough
- seems there are ~20k game states so with only 1k, we can only search 5% of game states?
- with pure randomness, that isn't enough to avoid traps
- perhaps with a guided heuristic, 1k would be enough
- but still, we are able to guarantee (as far as my tests) a non-loss with 10k simulations,
  which is only 50% of the game space.

## 2025-05-28
- Implement game logic
- Implemented human agent
- Implemented random agent
- Next steps: implement MCTS agent
