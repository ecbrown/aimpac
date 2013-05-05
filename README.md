This is a fork of the Github qtaim/aimpac repository. The original version of AIMPAC can be downloaded from:

<http://www.chemistry.mcmaster.ca/aimpac/>

WORK IN PROGRESS
================

If you have found this page, and this notice is still here, then please know that this *does not work yet*

Please send an email to me and *motivate* me to get this finished.

Disclaimer
==========

The software in this repository is provided as a convenience to the
community. It is provided as-is and where-is, and no warranty for any
purpose is expressed or implied.

Motivation
==========

I had some difficulty compiling the original version of AIMPAC, the
reference implementation of the Quantum Theory of Atoms in Molecules
(QTAIM). This is my attempt to modify (minimally) the AIMPAC code so
that it compiles with a modern Fortran compiler, on a UNIX-like
operating system. 

A second motivation is to remove the "fixed form" input required by
the original source. The original code is very particular about how
the input decks should be specified, and this is inconvenient for the
user.

Instructions
============

0. *Please note: Windows is not UNIX!* If you are using a Windows
system, then you are on your own.  If you insist on going forward, you
may find it necessary to install a Linux virtual machine on your
computer, and then continue along with these instructions.

1. Clone the repository:

    git clone https://github.com/ecbrown/aimpac.git

2. Obtain a Fortran Compiler.  (I use gfortran version 4.7)

3. Move to the aimpac/pgplot directory and follow the instructions for building on your system.

4. Move back to the aimpac directory and type:

    make

This will create a set of binary files:
    bubble.x
    contor.x
    cubev.x
    envelop.x
    ext94b.x
    grdvec.x
    proaimv.x
    relief.x
    schuss.x


Documentation
=============

The instructions for using each binary are contained in the
corresponding "man" files.

Feedback
========

Please send comments and suggestions to:

Eric Brown

<eric.c.brown@mac.com>

