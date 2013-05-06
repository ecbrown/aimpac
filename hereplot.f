c
c-----------------------------------------------------------------------
c
      subroutine plots (scalex,scaley,file)
        character*(*) file
        call pgbegin(0,file,1,1)
*       call pgscr(0, 1.,1.,1.)
        call pgscr(1, 1.,0.,0.)
        call pgscr(2, 0.,1.,0.)
        call pgscr(3, 0.,0.,1.)
        call pgscr(4, 1.,1.,0.)
        call pgscr(5, 1.,0.,1.)
        call pgscr(6, 0.,1.,1.)
        call pgscr(7, 1.0,0.5,0.5)
        call pgscr(8, 0.5,1.0,0.5)
        call pgscr(9, 0.5,0.5,1.0)
        call pgvport (0.,1.,0.,1.)
*       call pgenv(0,scalex,0,scaley,1,-2)
        call pgenv(0,scalex,0,scaley,1,-1)
      end
c
c-----------------------------------------------------------------------
c
      subroutine plots2 (scalex,scaley,file,line)
        character*(*) file, line
        character*(20) ejex, ejey
        call pgbegin(0,file,1,1)
*mdc*if color
*        call pgscr(0, 1.,1.,1.)
*        call pgscr(1, 1.,0.,0.)
*        call pgscr(2, 0.,1.,0.)
*        call pgscr(3, 0.,0.,1.)
*        call pgscr(4, 1.,1.,0.)
*        call pgscr(5, 1.,0.,1.)
*        call pgscr(6, 0.,1.,1.)
*        call pgscr(7, 1.0,0.5,0.5)
*        call pgscr(8, 0.5,1.0,0.5)
*        call pgscr(9, 0.5,0.5,1.0)
*mdc*else
*mdc*endif
        call pgvport (0.,1.,0.,1.)
*       call pgenv(0,scalex,0,scaley,1,-2)
        call pgenv(0,scalex,0,scaley,1,-1)
        ejex = ' '
        ejey = ' '
        call pglab(ejex,ejey,line(1:leng(line)))
      end
c
c-----------------------------------------------------------------------
c
      subroutine plot(x,y,ipen)
      real xx(1), yy(1)
c
      if (ipen.eq.999) then
c
          call pgend
          return
c
      elseif (ipen.eq.3) then
c
          call pgmove(x,y)
c
      elseif (ipen.eq.2) then
c
          call pgsls(1)
*mdc*if color
*          call pgsci(1)
*mdc*endif
          call pgdraw(x,y)
c
      elseif (ipen.eq.5) then
          call pgsls(2)
*mdc*if color
*          call pgsci(3)
*mdc*endif
*mdc*if trial2
*          call pgmove(x,y)
*          xx(1) = x
*          yy(1) = y
*          call pgpt(1,xx,yy,-1)
*mdc*else
          call pgdraw(x,y)
*mdc*endif
c
      elseif (ipen.gt.3) then
c
          call pgsls(ipen-1)
*mdc*if color
*          call pgsci(ipen-3)
*mdc*endif
          call pgdraw(x,y)
c
      endif
c
      end
c
c-----------------------------------------------------------------------
c
      subroutine plot_line(n,xx,yy,ipen)
      integer n, ipen
      real xx(n), yy(n)
c
      if (ipen.eq.2) then
          call pgsls(1)
*mdc*if color
*          call pgsci(1)
*mdc*endif
c
      elseif (ipen.eq.5) then
c
          call pgsls(4)
*mdc*if color
*          call pgsci(3)
*mdc*endif
c
      elseif (ipen.gt.3) then
c
          call pgsls(ipen-1)
*mdc*if color
*          call pgsci(ipen-3)
*mdc*endif
c
      endif
c
      call pgline(n,xx,yy)
c
      end
c
c-----------------------------------------------------------------------
c
      integer function leng (string)
c
c.....leng - obtains the leng of the string, assuming that the blancs at
c     the end are dummy.
c
      character*(*)     string
      character*(1)     blank
      data blank /' '/
c
      do 10 i = len(string), 1, -1
         if (string(i:i) .ne. blank) then
            leng = i
            return
         endif
 10   continue
      leng = 0
      return
      end
