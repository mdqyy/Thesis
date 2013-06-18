#!/usr/bin/python

from urllib2 import *
from BeautifulSoup import BeautifulSoup as BS
import re

flickr = "http://www.flickr.com/"
query = "blood_violence"

imagesLinks = []
imagesTitles = []
for i in range(20):
    flickrSearch = flickr + "search/?" + "q=" + query + "&page=" +str(i)
    r1 = BS(''.join(urlopen(flickrSearch).read()))
    r2 = r1.findAll('div', id = "photo-display-container")[0]
    for j in range(len(r2)):
        if(j%2==0):
            continue
        for k in range(len(r2.contents[j])):
            link = r2.contents[j].contents[k].contents[1].contents[1].contents[1].contents[1].contents[0]['data-defer-src'];
            if(link not in imagesLinks and len(link)>4 and link[0:4]=='http'):
                imagesLinks.append(link)
                imagesTitles.append(r2.contents[j].contents[k].contents[1].contents[1].contents[1].contents[1]['title'])

f1 = open('image_links.txt', 'w')
f2 = open('image_titles.txt', 'w')
for a in zip(imagesLinks, imagesTitles):
    f1.write(a[0].encode('utf8')+'\n')
    f2.write(a[1].encode('utf8')+'\n')

f1.close()
f2.close()


