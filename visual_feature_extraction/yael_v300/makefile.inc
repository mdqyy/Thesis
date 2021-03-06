
# generated by ./configure.sh 

CFLAGS=-fPIC -Wall -g -O3 
LDFLAGS=-g -fPIC 

PYTHONCFLAGS = -I/usr/include/python2.6

YAELCONF=linux64
YAELCFLAGS=-I/mnt/has2_database1/gunji/ilsvrc_fv_desc/yael_v300
YAELLDFLAGS=-L/mnt/has2_database1/gunji/ilsvrc_fv_desc/yael_v300/yael -Wl,-rpath,/mnt/has2_database1/gunji/ilsvrc_fv_desc/yael_v300/yael -lyael


SWIG=swig -python

WRAPLDFLAGS=-shared
LAPACKLDFLAGS=/usr/lib/libblas.so.3gf /usr/lib/liblapack.so.3gf
LAPACKCFLAGS=-DFINTEGER=int

USEARPACK=no
ARPACKLDFLAGS=/usr/lib64/libarpack.so.2

USETHREADS=yes
THREADCFLAGS=-DHAVE_THREADS

SHAREDEXT=so
SHAREDFLAGS=-shared
YAELSHAREDFLAGS=-shared

USENUMPY=
NUMPYCFLAGS=
NUMPYSWIGFLAGS=


USEOPENMP=yes


