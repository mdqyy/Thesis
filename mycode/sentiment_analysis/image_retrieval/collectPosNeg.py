from senti_classifier import senti_classifier
from queryImages import queryImages

queries = [x.split(';')[1] for x in \
           open('flickr_sentiwords.queries.csv').read().split('\n') if len(x.split(';'))>=2]

senti_scores = [senti_classifier.polarity_scores([x]) for x in queries]
pos_scores = sorted(zip(senti_scores, queries), key=lambda x : -x[0][0])
neg_scores = sorted(zip(senti_scores, queries), key=lambda x : -x[0][1])

numQueries = 20

f = open('database.csv', 'w')

for data in neg_scores[0:numQueries]:
    q = data[1]
    links, titles = queryImages(q, 20, 50)
    for i in range(len(links)):
        f.write((str(data[0][0]) + ";"+str(data[0][1])+";"+str(data[1])+";"+links[i]+";"+titles[i]+"\n").encode('utf8'))

f.close()




