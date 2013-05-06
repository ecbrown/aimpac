# Mac OS X 10.8 (g95)
#FC = g95 
#FFLAGS = -fbounds-check -freal-loops -fsloppy-char -O2 -fPIC -m32
#OS = macosx
#COMPILER = g95_gcc_32
#X11=/usr/X11/lib/libX11.dylib

# Mac OS X 10.8 (gfortran)
#FC = gfortran
#FFLAGS = -fbounds-check -O2 -fPIC -m64
#OS = macosx
#COMPILER = gfortran_gcc_64
#X11=/usr/X11/lib/libX11.dylib

# Debian 7.0 (wheezy)
#OS = linux
#COMPILER = gfortran_gcc_64
#X11=/usr/lib/x86_64-linux-gnu/libX11.so

# Debian 7.0 (wheezy, Intel Fortran)
FC = ifort
FFLAGS = -check bounds -O2 -fPIC -m64
OS = linux
COMPILER = ifort_icc_64
X11=/usr/lib/x86_64-linux-gnu/libX11.so

all : contor.x cubev.x ext94b.x gridv.x grdvec.x profil.x proaimv.x

broken : bubble.x envelop.x relief.x schuss.x

nopgplot : bubble.x cubev.x ext94b.x proaimv.x

pgplot : pgplot_src
	rm -rf pgplot_build ;\
	mkdir pgplot_build ;\
	cd pgplot_build ;\
	cp ../pgplot_src/drivers.list . ;\
	../pgplot_src/makemake ../pgplot_src $(OS) $(COMPILER) ;\
	make all

bubble.x : bubble.f
	$(FC) $(FFLAGS) -o bubble.x bubble.f

contor.x : pgplot contorpg.f hereplot.f
	$(FC) $(FFLAGS) -o contor.x hereplot.f contorpg.f -Lpgplot_build -lpgplot $(X11)

cubev.x : cubev.f
	$(FC) $(FFLAGS) -o cubev.x cubev.f

envelop.x : envelop.f
	$(FC) $(FFLAGS) -o envelop.x envelop.f

ext94b.x : ext94b.f
	$(FC) $(FFLAGS) -o ext94b.x ext94b.f

gridv.x : gridv.f
	$(FC) $(FFLAGS) -o gridv.x gridv.f

grdvec.x : pgplot grdvecpg.f hereplot.f
	$(FC) $(FFLAGS) -o grdvec.x hereplot.f grdvecpg.f -Lpgplot_build -lpgplot $(X11)

proaimv.x : proaimv.f
	$(FC) $(FFLAGS) -o proaimv.x proaimv.f

profil.x : profil.f dgemm/lsame.f dgemm/xerbla.f dgemm/dgemm.f 
	$(FC) $(FFLAGS) -o profil.x dgemm/lsame.f dgemm/xerbla.f dgemm/dgemm.f profil.f

relief.x : relief.f
	$(FC) $(FFLAGS) -o relief.x relief.f

schuss.x : schuss.f
	$(FC) $(FFLAGS) -o schuss.x schuss.f

clean :
	rm -f bubble.x contor.x cubev.x envelop.x ext94b.x grdvec.x profil.x proaimv.x relief.x schuss.x ;\
	rm -rf pgplot_build
