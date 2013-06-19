import urllib

def downloadImages(links):
    for i in range(len(links)):
        name = '%(number)05d.jpg' % {"number":i}
        urllib.urlretrieve(links[i], name)