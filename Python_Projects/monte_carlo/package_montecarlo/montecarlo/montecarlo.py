# -*- coding: utf-8 -*-
"""
Created on Thu Aug  3 08:09:42 2023

@author: treyb
"""

import pandas as pd
import numpy as np
import random
from itertools import product
from itertools import combinations_with_replacement

class Die:
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
    
    face_weight_df = pd.DataFrame({})
    
    def __init__(self, faces):
        '''Takes in faces of the die. Initializer method for the Die class.'''
        
        self.faces = faces
        self.weights = np.ones(len(faces))
        
        if not type(faces) is np.ndarray:
            raise TypeError("Only numpy arrays are allowed.")
            
        if not len(faces) == len(np.unique(faces)):
            raise ValueError("Values of numpy array are not distinct.")
            
        self.face_weight_df = pd.DataFrame({'weights':np.ones(len(faces))}, index=faces)

        
        
    def change_weight(self, face, new_weight):        
        '''Method to change the weights of dice. Parameters are the face you want to change, and the 
            new weight of the face.'''
        
        try:
            if face in self.face_weight_df.index:
                self.face_weight_df.loc[face] = new_weight
            else:
                raise IndexError("The face you are trying to replace does not exist.")
        except:
            raise TypeError("Enter a valid data type")
        
    def roll_die(self, rolls = 1):
        '''Method to roll the dice. Default number of rolls is 1, but user can specify how many are needed.'''
        
        roll_outcome = random.choices(self.face_weight_df.index, weights=self.face_weight_df['weights'], k=rolls)
        return roll_outcome
        
    def die_current_state(self):
        '''Method to get the current state of the die. Returns dataframe of faces and weights.'''
        
        return self.face_weight_df
    
    
    
class Game:
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
    
    df_die = pd.DataFrame({})
    
    def __init__(self, list_of_die_obj):
        '''Takes in Die object. Initializer method for the Game class.'''
        
        self.list_of_die_obj = list_of_die_obj
        
    def play(self, die_rolls):
        '''Takes in how many rolls of dice are wanted. Takes in an integer.'''
        
        dde = []
        for dice in self.list_of_die_obj:
            dde.append(dice.roll_die(rolls=die_rolls))
        self.df_die = pd.DataFrame(dde)
        self.df_die = self.df_die.transpose()
        self.df_die.index += 1
        self.df_die.columns += 1

    def results_recent_play(self, wide=True):
        '''Returns the recent results of the dice roll in wide format my default.'''
        
        if wide == True:
            return self.df_die
        elif wide == False:
            return self.df_die.transpose().unstack()
        else:
            raise ValueError('The wide parameter should be either True or False.')
            
    def get_faces(self):
        '''Returns faces of the dice.'''
        
        return list(self.list_of_die_obj[0].die_current_state().index)
    
    
    
class Analyzer:
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
    
    def __init__(self, game_obj):
        '''Initializer method that takes in a game object.'''
        
        self.game_obj = game_obj
        if type(game_obj) != Game:
            raise ValueError("The passed value is not a game object.") 
        
    def jackpot(self):
        '''A jackpot is a result in which all faces are the same. Computes how many times the game resulted in a jackpot.'''

        try:
            count_jackpot = 0
    
            for i in self.game_obj.results_recent_play().transpose():
                if len(set(self.game_obj.results_recent_play().iloc[i]))==1:
                    count_jackpot += 1
        except IndexError:
            pass
        return count_jackpot
        
    def get_faces_analyzer(self):
        '''Get the faces of the game object.'''
        
        return self.game_obj.get_faces()
    
    
    

    def face_counts_per_roll(self):
        '''Get the face counts per roll of the game object.'''
        
        faces_df = pd.DataFrame(self.game_obj.get_faces())
        faces_df.columns = ['john']

        yuh = self.game_obj.results_recent_play().transpose()
        yuh.rename(columns={1:'john'}, inplace=True)

        emp = []
        for i in yuh:
            ddd = pd.concat([faces_df, yuh[i]])
            eee = ddd['john'].fillna(ddd[0])
            emp.append(eee.value_counts()-1)
            
        final = pd.DataFrame(emp).reset_index(drop=True)
        final.index += 1

        final = final.reindex(sorted(final.columns), axis=1)
        
        self.final = final
        
        return final
  

    def permutation_count(self):
        '''Method to compute the distinct permutations of faces rolled, along with their counts.'''

        
        def distinct_combinations(values, n):
            return set(product(values, repeat=n))

        # Compute distinct combinations
        combinations = distinct_combinations(self.game_obj.get_faces(), len(self.game_obj.results_recent_play()))

        # Create a DataFrame from the distinct combinations
        columns = [f'Die{i+1}' for i in range(len(self.game_obj.results_recent_play()))]
        combos = pd.DataFrame(list(combinations), columns=columns)
        
        combos = combos.set_index(columns)
        combos['combos'] = combos.index
        combos['combos'].astype(str)
        
        outcome = self.game_obj.results_recent_play()
        outcome = outcome.transpose()
        outcome_tuples = outcome.apply(lambda row: tuple(row), axis=1)
        
        
        final_combo = pd.concat([combos,outcome_tuples])
        final_combo['Col1'] = final_combo['combos'].astype(str)
        final_combo['Col2'] = final_combo[0].astype(str)
        final_combo = final_combo[['Col1', 'Col2']]
        final_combo = final_combo.replace('nan', '')
        final_combo['Col3'] = final_combo['Col1'] + final_combo['Col2']
        final_combo = final_combo['Col3'].value_counts()-1
        final_combo = final_combo.sort_index()
        #final_combo = final_combo.to_frame()
        combos = combos.sort_index()
        combos['value_counts'] = list(final_combo)
        combos = combos.drop(columns=['combos'])
        
        return combos
        
        
    def combo_count(self):
        '''Method to compute the distinct combinations of faces rolled, along with their counts.'''
        
        def distinct_combinations(lst, input_list_length):
            unique_combinations = set()
            
            for combo in combinations_with_replacement(lst, input_list_length):
                unique_combinations.add(tuple(sorted(combo)))
            
            return [list(combo) for combo in unique_combinations]
        
        combinations = distinct_combinations(self.game_obj.get_faces(), len(self.game_obj.results_recent_play()))
        

        columns = [f'Die{i+1}' for i in range(len(self.game_obj.results_recent_play()))]
        combos = pd.DataFrame(list(combinations), columns=columns)
        
        combos = combos.set_index(columns)
        combos['combos'] = combos.index
        combos['combos'].astype(str)
        
        outcome = self.game_obj.results_recent_play()
        outcome = outcome.transpose()
        outcome_tuples = outcome.apply(lambda row: tuple(row), axis=1)
        
        sorted_tuples = []

        for plop in range(len(outcome_tuples)):
            sorted_tuples.append(tuple(sorted(outcome_tuples.iloc[plop])))

        outcome_tuples = pd.Series(sorted_tuples)
        final_combo = pd.concat([combos,outcome_tuples])
        final_combo['Col1'] = final_combo['combos'].astype(str)
        final_combo['Col2'] = final_combo[0].astype(str)
        final_combo = final_combo[['Col1', 'Col2']]
        final_combo = final_combo.replace('nan', '')
        final_combo['Col3'] = final_combo['Col1'] + final_combo['Col2']
        final_combo = final_combo['Col3'].value_counts()-1
        final_combo = final_combo.sort_index()
        combos = combos.sort_index()
        combos['value_counts'] = list(final_combo)
        combos = combos.drop(columns=['combos'])


        return combos







