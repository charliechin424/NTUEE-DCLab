GreedySnake
This is a verilog Snake game implemented on DE2-115. The final project of NTUEE 2023 fall dclab.

Introduction
The game objective is straightforward: players need to control a snake to eat randomly generated apple. Each time the snake consumes apple, its body grows longer. The challenge of the game lies in keeping the snake alive and making it as long as possible. In our modified version of the game, we have transformed it into a two-player version. We also added some of our own creative elements, such as the "multiple apples" feature and the "bomb" function, enhancing the gameplay of the two-player mode.

Game Steps
Connect to VGA display and PS2 keyboard
Set SW[3] and SW[4] to high, and press key0 to enter the game screen.
As soon as either player presses any key (W, A, S, D, I, J, K, L), the game starts.
During the game, if a player hits a wall, collides with their own body, collides with the opponent's body, or gets killed by a bomb, the game ends.
After the game ends, the screen will display which player won. Press any key (W, A, S, D, I, J, K, L) at this point to return to the game screen.
Demo video
