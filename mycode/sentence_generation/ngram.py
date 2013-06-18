from math import log
import re
import nltk
import re
from nltk.corpus import wordnet as wn
from nltk.corpus import stopwords

def execute():
    execfile('ngram.py')

# Increment value
def increment(d, element, value = 1):
    if(d.has_key(element)):
        d[element] = d[element] + value
    else:
        d[element] = value

'''
********************************************************************
Ngram Model
'''

class Ngram(object):
    # Initialization
    def __init__(self, n = 2):
        self.ngram = [{}, {},{}]
        self.corpus = []
        self.sortedScore = []

    # Count ngrams
    def count(self):
        for sent in self.corpus:
            l = len(sent)
            for i in range(l-2):
                for j in range(3):
                    increment(self.ngram[j], ' '.join(sent[i:i+j+1]))
            increment(self.ngram[1],". "+sent[0])
            increment(self.ngram[1],sent[l-1]+" .")
            increment(self.ngram[1],sent[l-2]+" "+sent[l-1])
            increment(self.ngram[2],". "+sent[0]+" "+sent[1])
            increment(self.ngram[2],sent[l-2]+" "+sent[l-1]+" .")

    # Create corpus from files
    def createCorpus(self, filenames):
        filepattern = re.compile(r"[.\n]") # Split file into sentences
        sentpattern = re.compile(r"[, ]")  # Split sentences to tokens
        for filename in filenames:
            f = open(filename,'r')
            self.corpus.extend([[verbMorphy(ch.lower()) for ch in sentpattern.split(sent) if ch!=''] for sent in filepattern.split(f.read()) if len(sent)>5])
            f.close()
        return self.corpus

    # Generate sentences
    def generate(self, weight =[1.0,0.1]):
        score = dict()
        for gram in self.ngram[2]:
            score[gram] = weight[0]*self.ngram[2][gram] + weight[1]*self.ngram[1][' '.join(gram.split()[1:3])]
        self.sortedScore = sorted(score.items(), key = lambda x : -x[1])

        ### Left --> Right
        a = self.sortedScore[0][0].split()[1]
        b = self.sortedScore[0][0].split()[2]
        sentence = a+" "+b
        while(b!='.'):
            print sentence
            for gram in self.sortedScore:
                split = gram[0].split()
                if(split[0]==a and split[1]==b):
                    a = b
                    b = split[2]
                    break
            sentence = sentence + " " + b

        ### Right --> Left
        a = self.sortedScore[0][0].split()[0]
        b = self.sortedScore[0][0].split()[1]
        while(a!='.'):
            print sentence
            for gram in self.sortedScore:
                split = gram[0].split()
                if(split[1]==a and split[2]==b):
                    b = a
                    a = split[0]
                    break
            sentence = a + " " + sentence
        return sentence

'''
********************************************************************
Ngram Model
'''

def verbMorphy(word):
    mor = wn.morphy(word, wn.VERB)
    if(mor == None):
        return word
    else:
        return mor



image_dir = '/home/letrungkien7/Work/2011_acmmgc/PASCALSentence/bicycle/'
f = open('similar.txt', 'r')
similar_files = [image_dir+ text +'.txt' for text in f.readline().split()];
f.close()
ng = Ngram()
ng.createCorpus(similar_files)
ng.count()
