#!/usr/bin/python

from urllib2 import *
from BeautifulSoup import BeautifulSoup as BS
import re

flickr = "http://www.flickr.com/"

def queryImages(query = "", numpages = 10, maxImages = 50):
    imagesLinks = []
    imagesTitles = []
    for i in range(numpages):
        flickrSearch = flickr + "search/?" + "q=" + query + "&page=" +str(i)
        if(len(imagesLinks)>maxImages):
            break
        try:
            r1 = BS(''.join(urlopen(flickrSearch).read()))
            r2 = r1.findAll('div', id = "photo-display-container")[0]
            for j in range(len(r2)):
                if(j%2==0):
                    continue
                for k in range(len(r2.contents[j])):
                    if(len(imagesLinks)>maxImages):
                        break
                    link = r2.contents[j].contents[k].contents[1].contents[1].contents[1].contents[1].contents[0]['data-defer-src'];
                    if(link not in imagesLinks and len(link)>4 and link[0:4]=='http'):
                        imagesLinks.append(link)
                        imagesTitles.append(r2.contents[j].contents[k].contents[1].contents[1].contents[1].contents[1]['title'])
        except IOError:
            print "Cannot download"
    return imagesLinks, imagesTitles


