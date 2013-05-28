#!/usr/bin/python

from urllib2 import *
from BeautifulSoup import BeautifulSoup as BS
import re

flickr = "http://www.flickr.com/"
flickrSearch = flickr + "search/?q="

query = "Dog_Run"
r1 = BS(''.join(urlopen(flickrSearch+query).read()))

r2 = r1.findAll('div', id = "ResultsThumbsDiv")
r3 = r2[0].findAll('a')
r4 = [text for text in r3 if len(text['title'])>20]

imagesLinks = [text['href'] for text in r4]
imagesTitles = [text['title'] for text in r4]





