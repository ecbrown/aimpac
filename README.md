This is a fork of the Github qtaim/aimpac repository. The original version of AIMPAC can be downloaded from:

<http://www.chemistry.mcmaster.ca/aimpac/>

Disclaimer
==========

The software in this repository is provided as a convenience to the
community. It is provided as-is and where-is, and no warranty for any
purpose is expressed or implied. Use them at your own risk.


WORK IN PROGRESS
================

If you have found this page, and this notice is still here, then
please know that *not everything works yet*

Please send an email to help motivate me to get this finished.

Though I wish AIMPAC to work with (at least) gfortran on any UNIX-like
operating system, currently I have these working with *ifort* on
*Debian Wheezy*.  It may work with ifort on OS X, but I don't have
access to that compiler (because it is not free.)

These AIMPAC programs compile and run the sample files without error:

    bubble
    contor
    cubev
    ext94b
    grdvec
    gridv
    proaimv
    profil

*Note that contor and grdvec are the AIMPACPG (PGPLOT) versions. Please see below for setting the environment variable PGPLOT_DIR*

These AIMPAC programs do not compile/do not run:
    envelop
    relief
    schuss

because they have not been ported to PGPLOT, and/or their plot
subroutines are not coded.



Motivation
==========

I had some difficulty compiling the original version of AIMPAC, the
reference implementation of the Quantum Theory of Atoms in Molecules
(QTAIM). This is my attempt to modify (minimally) the AIMPAC code so
that it compiles with a modern Fortran compiler, on a UNIX-like
operating system. (Currently it works with ifort.)

A second motivation is to remove the "fixed form" input required by
the original source. The original code is very particular about how
the input decks should be specified, and this is inconvenient for the
user. (I have not made much progress on this.)

Instructions
============

0. *Please note: Windows is not UNIX!* If you are using a Windows
system, then you are on your own.  If you insist on going forward, you
may find it necessary to install a Linux virtual machine on your
computer, and then continue along with these instructions.

1. Clone the repository:

    git clone https://github.com/ecbrown/aimpac.git

2. Obtain a Fortran Compiler.  (I use ifort 2013 on Debian Wheezy)

3. Enter the aimpac directory and type:

    make all

This will create a set of binary files:
    bubble.x
    contor.x
    cubev.x
    ext94b.x
    grdvec.x
    gridv.x
    proaimv.x
    profil.x

You may have to edit the Makefile to change the compiler, flags, or X11 location to match your system.

If PGPLOT seems broken, then you could type:

    make nopgplot

and you will then have this set of binary files:

    bubble.x
    cubev.x
    ext94b.x
    gridv.x
    proaimv.x
    profil.x

which will still provide the most useful programs of AIMPAC with respect to performing QTAIM calculations.

4. You must set the PGPLOT_DIR environment variable:
    export PGPLOT_DIR=/home/brown/aimpac/pgplot_build

either in your current shell or in your ~/.bashrc file. (Don't forget
to source, or log out and then log back in!)

Documentation
=============

The instructions for using each binary are contained in the
corresponding "man" files.

Feedback
========

Please send comments and suggestions to:

Eric Brown

<eric.c.brown@mac.com>

