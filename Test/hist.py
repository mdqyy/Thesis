import matplotlib.pyplot as plt
import numpy as np

data = [x[1] for x in ng.ngram[1].items()]
hist, bins = np.histogram(data)
width = 0.7*(bins[1]-bins[0])
center = (bins[:-1]+bins[1:])/2
plt.bar(center, hist, align = 'center', width = width)
plt.ylabel('Number of trigram')
plt.xlabel('Bigram count')
plt.savefig('bigram.png', dpi = 100)
plt.show()

