# montecarlo

## **Metadata**: 
  
  Name: Thomas Burrell
  
  Project Name: Monte Carlo Simulator




## **Synopsis**:
  Brief Demo Code:
  ```
  
    obj = Die(np.array(['H', 'T']))
    obj2 = Die(np.array(['H', 'T']))
    list_of_die = [obj, obj2]
    
    game_obj = Game(list_of_die)
    game_obj.play(7)
    
    game_obj.get_faces()
    game_obj.results_recent_play()
    
    analyze = Analyzer(game_obj)
    analyze.jackpot()
    
    analyze.face_counts_per_roll()
    analyze.permutation_count()
    analyze.combo_count()
    
  ```

  How to Install:
  
    pip install montecarlo

  How to Import:
  
    from montecarlo import Die
    
    from montecarlo import Game
    
    from montecarlo import Analyzer
    
    import pandas as pd
    
    import numpy as np
    
    import random
    
    from itertools import product
    
    from itertools import combinations_with_replacement
    
    import matplotlib.pyplot as plt
  
## **API description**:

 **class Die:**

    """
    A class representing a n-sided die.

    This class provides functionality to create a dataframe that displays the faces
    of a standard six-sided die along with their corresponding weights, and allows
    the user to roll the die to get a random outcome.


    Methods:
    -------
    change_weight(face, new_weight)
        Changes the weights of faces of a n-sided die. The user can determine
        which faces to change.
        
        Takes two parameters, face, which is a string or integer and weight which is 
        a numeric value.
        
        
     roll_die(rolls)
         Rolls the die and returns a random outcome.
         
         Takes one parameter, the number of rolls a user wants to have.
         
    
    die_current_state()
        Return the current state of the die, which is the faces and corresponding
        weights.
        
    """



  **class Game:**
    
    """
    A class representing a game of n amount of dice.

    This class provides functionality to play a game of rolling n-sided dice,
    with random outcomes. It uses Die objects created from the Die class.

    Methods:
    -------
    play(die_rolls)
        Rolls n-sided die a specified number of times. This value is an integer.
        
        Takes one parameters, die rolls. This is how many times we want to roll
        the dice previously specified in the Die object.
        
        
     results_recent_play(wide=True)
         Returns the results of the most recent play, which shows the dice number in
         the columns and the roll number as the rows. The cells represent the outcome, 
         which is the face that was rolled.
         
         Takes one parameter, wide, which returns a wide form dataframe if left to default.
         It returns a narrow dataframe if wide=False.
         
    
    get_faces()
        Return the faces of the dice.
        
    """


  **class Analyzer:**
    
    
    """
    A class representing analysis of a Game object.

    This class provides functionality to determine if a game resulted in a jackpot,
    the specific combination and permutation that was rolled.

    Methods:
    -------
    jackpot()
        A jackpot is a result in which all faces are the same, e.g. all ones for a six-sided die.
        
        Returns how many times the game resulted in a jackpot as an integer.
        
        
     get_faces_analyzer()
         Return the faces of the dice.
         
    
    face_counts_per_roll()
        Computes how many times a given face is rolled in each event. Returns a data frame of results. 
        The data frame has an index of the roll number, face values as columns, and count values in the cells.
        
    permutation_count()
        Computes the distinct permutations of faces rolled, along with their counts.
        Returns a data frame of results. The data frame has an MultiIndex of distinct permutations and a 
        column for the associated counts.
        
    combo_count()
        Computes the distinct combinations of faces rolled, along with their counts.
        Returns a data frame of results. The data frame has an MultiIndex of distinct combinations and a 
        column for the associated counts.
    """
