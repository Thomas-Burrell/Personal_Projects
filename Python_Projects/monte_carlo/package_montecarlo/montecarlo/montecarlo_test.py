# -*- coding: utf-8 -*-
"""
Created on Mon Aug  7 16:56:09 2023

@author: treyb
"""

import unittest
from montecarlo import Die
from montecarlo import Game
from montecarlo import Analyzer
import pandas as pd
import numpy as np
import random
from itertools import product
from itertools import combinations_with_replacement



class montecarloTestSuite(unittest.TestCase):

    def test_DIECLASS_default_weight(self): 
        # add a book and test if it is in `book_list`.
        
        die1 = Die(np.array(['H', 'T']))
        self.assertEqual(die1.die_current_state()['weights'][0], [1.0])
        
    def test_DIECLASS_change_weight(self):
        die1 = Die(np.array(['H', 'T']))

        die1.change_weight('H', 2.0)
        self.assertEqual(die1.die_current_state()['weights'][0], [2.0])
        
    def test_DIECLASS_rolldie_length(self):
        die1 = Die(np.array(['H', 'T']))
        
        self.assertEqual(len(die1.roll_die(4)), 4)

    def test_DIECLASS_rolldie_datatype(self):
        die1 = Die(np.array(['H', 'T']))
        
        self.assertEqual(type(die1.roll_die(4)), list)
        
    def test_DIECLASS_currentstate(self):
        die1 = Die(np.array(['H', 'T']))
        
        self.assertEqual(type(die1.die_current_state()), pd.DataFrame)
        
        
        
    def test_GAMECLASS_play(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        game_obj.play(4)
        
        self.assertEqual(len(game_obj.results_recent_play()), 4)
        
    def test_GAMECLASS_resultsrecentplay(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        game_obj.play(4)
        
        self.assertEqual(type(game_obj.results_recent_play()), pd.DataFrame)
        
    def test_GAMECLASS_getfaces(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        
        self.assertEqual(game_obj.get_faces(),['H', 'T'])
        
        
    
    def test_ANALYZERCLASS_jackpot(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        game_obj.play(2)
        
        analyze_obj = Analyzer(game_obj)
        
        
        self.assertEqual(type(analyze_obj.jackpot()), int)

    def test_ANALYZERCLASS_get_faces_analyzer(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        game_obj.play(2)
        
        analyze_obj = Analyzer(game_obj)
        
        
        self.assertEqual(analyze_obj.get_faces_analyzer(),['H', 'T'])
        
        
    def test_ANALYZERCLASS_face_counts_per_roll(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   
        
        game_obj = Game(list_of_die)
        game_obj.play(2)
        
        analyze_obj = Analyzer(game_obj)
        
        self.assertEqual(type(analyze_obj.face_counts_per_roll()), pd.DataFrame)

    def test_ANALYZERCLASS_permutation_count(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   

        game_obj = Game(list_of_die)
        game_obj.play(2)

        game_obj.get_faces()
        game_obj.results_recent_play()

        analyze_obj = Analyzer(game_obj)
        analyze_obj.face_counts_per_roll()
        
        self.assertEqual(type(analyze_obj.permutation_count()), pd.DataFrame)

    def test_ANALYZERCLASS_combo_count(self):
        die1 = Die(np.array(['H', 'T']))
        list_of_die = [die1]   

        game_obj = Game(list_of_die)
        game_obj.play(2)

        game_obj.get_faces()
        game_obj.results_recent_play()

        analyze_obj = Analyzer(game_obj)
        analyze_obj.face_counts_per_roll()
        
        self.assertEqual(type(analyze_obj.combo_count()), pd.DataFrame)
        


if __name__ == '__main__':

    unittest.main(verbosity=3)