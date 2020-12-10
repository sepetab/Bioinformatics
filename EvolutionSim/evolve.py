import re
import sys
import os
import random
from Bio import SeqIO

#Below are the rows of the matrix
row0=("9867,2,9,10,3,8,17,21,2,6,4,2,6,2,22,35,32,0,2,18").split(",")
row1=("1,9914,1,0,1,10,0,0,10,3,1,19,4,1,4,6,1,8,0,1").split(",")
row2=("4,1,9822,36,0,4,6,6,21,3,1,13,0,1,2,20,9,1,4,1").split(",")
row3=("6,0,42,9859,0,6,53,6,4,1,0,3,0,0,1,5,3,0,0,1").split(",")
row4=("1,1,0,0,9973,0,0,0,1,1,0,0,0,0,1,5,1,0,3,2").split(",")
row5=("3,9,4,5,0,9876,27,1,23,1,3,6,4,0,6,2,2,0,0,1").split(",")
row6=("10,0,7,56,0,35,9865,4,2,3,1,4,1,0,3,4,2,0,1,2").split(",")
row7=("21,1,12,11,1,3,7,9935,1,0,1,2,1,1,3,21,3,0,0,5").split(",")
row8=("1,8,18,3,1,20,1,0,9913,0,1,1,0,2,3,1,1,1,4,1").split(",")
row9=("2,2,3,1,2,1,2,0,0,9871,9,2,12,7,0,1,7,0,1,33").split(",")
row10=("3,1,3,0,0,6,1,1,4,22,9947,2,45,13,3,1,3,4,2,15").split(",")
row11=("2,37,25,6,0,12,7,2,2,4,1,9924,20,0,3,8,11,0,1,1").split(",")
row12=("1,1,0,0,0,2,0,0,0,5,8,4,9875,1,0,1,2,0,0,4").split(",")
row13=("1,1,1,0,0,0,0,1,2,8,6,0,4,9944,0,2,1,3,28,0").split(",")
row14=("13,5,2,1,1,8,3,2,5,1,2,2,1,1,9924,12,4,0,0,2").split(",")
row15=("28,11,34,7,11,4,6,16,2,2,1,7,4,3,17,9840,38,5,2,2").split(",")
row16=("22,2,13,4,1,3,2,2,1,11,2,8,6,1,5,32,9869,0,2,9").split(",")
row17=("0,2,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,9976,1,0").split(",")
row18=("1,0,3,0,3,0,1,0,4,1,1,0,0,21,0,1,1,2,9947,1").split(",")
row19=("13,2,1,1,3,2,2,3,3,57,11,1,17,1,3,2,10,0,2,9901").split(",")

#Initializing a dict to store matrix
AAMutation= {}

#Below array used to initialize matrix
Amino_acids = ['A','R','N','D','C','Q','E','G','H','I','L','K','M','F','P','S','T','W','Y','V']

#Below array used to randomize AminoAcids when checking for mutation
RAmino_acids = ['A','R','N','D','C','Q','E','G','H','I','L','K','M','F','P','S','T','W','Y','V']

#Initializing Matrix as 2d Dict
for x in Amino_acids:
    AAMutation[x] = {}
    Col=Amino_acids.index(x)
    for y in Amino_acids:
        Row=Amino_acids.index(y)
        AAMutation[x][y] = globals()["row"+str(Row)][Col]

#Check number of sequences and format
def CheckNumSeq(file):
    line_no=0
    for line in file:
        line_no = line_no + 1
        if line_no != 1 and line[0] == ">":
                print("Only one sequence per file is allowed")
                exit()
        if line_no ==1 and line[0] != ">":
                print("File should be in fasta format")
                exit()

#Returns random integer between 1 and 10000            
def mut_decider():
    return random.randint(1,10000)

#Mutates a sequence line and returns it
def mutate(line):
    returner = ''
    #print(line)
    for character in line:
        flag=0
        random.shuffle(RAmino_acids)
        for aa in RAmino_acids:
            #print(character + "," + aa)
            if mut_decider() < int(AAMutation[character][aa]):
                flag = aa
                break
        if flag==0:
            returner = returner + character
        else:
            returner = returner + flag
        #print("GOOOOOOOO")
    return returner
        
    
#checks file
CheckNumSeq(sys.stdin)

#file cursor goes back to line1
sys.stdin.seek(0)

#Reads from STDIN and prints mutated sequences to STDOUT
lines = []
next_lines = []
for x in range(1,502):
    if(x==1):
        print(">000")
        flag=0
        for line in sys.stdin:
            if(flag!=0):
                lines.append(line)
                print(line,end='')
            flag = flag + 1
        print('')
        sys.stdin.close()
    else:
        formatted = "{0:0=3d}".format(x-1)
        print(">" + formatted)
        for line in lines:
            mutated_line = mutate(line.rstrip())
            next_lines.append(mutated_line)
            print(mutated_line)
        lines.clear()
        for x in next_lines:
            lines.append(x)
        next_lines.clear()












    





  


