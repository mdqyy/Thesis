import urllib

f = open('image_links.txt')
links = f.read().split('\n')
f.close()

for i in range(len(links)):
    name = '%(number)05d.jpg' % {"number":i}
    urllib.urlretrieve(links[i], name)