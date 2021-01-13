
#define	T_IN	prhs[0]
#define	Y_IN	prhs[1]

/* Output Arguments */

#define	YP_OUT	plhs[0]
#include <stdio.h>
#include <math.h>
#include "mex.h"

double  *NFArray(int size)
{
	double	*p;
	p = (double *)mxCalloc(sizeof(*p),size);
	return p;
}
/***********************************************************************/
/* LONGCHAIN.C                                                         */
/* This function uses a long chain of first order                      */
/* allpass elements to warp a signal                                   */
/* USAGE: y=longchain(x,n,lam)                                         */
/* where y is the output of the filter, x is an input signal,          */
/* n<length(x) is the length of the produced warped signal and lam is  */
/* the warping parameter */
/*                                                                     */
/* Aki Härmä and Matti Karjalainen, Helsinki University of Technology, */
/* Laboratory of Acoustics and Audio Signal Processing                 */
/* This file is a part of the Warping toolbox available at             */
/* http://www.acoustics.hut.fi/software/warp/                          */
/***********************************************************************/
void trans(double *signal, long int len, double lam, 
	   long int tim, double *xm)
{
   double x,tmpr;
   int SIGLEN;
   int q,w,e,o;
   long int win;
   int sect; /* Number of transforms    */
   long int i=0;
   long int ind = 0;
   sect=len;  
   
   for(w=0;w<tim;w++)
      {
      x=signal[ind++];

     for(e=0; e <len; e++)
	    {
	    tmpr=xm[e]+lam*xm[e+1]-lam*x; /* The difference equation */
	    xm[e]=x;
	    x=tmpr;	    
	    }
      }
   /*for(q=0;q<len;q++)ret[q]=xm[q];*/
return;
}

#ifdef __STDC__
void mexFunction(
	int		nlhs,
	mxArray	*plhs[],
	int		nrhs,
	const mxArray	*prhs[]
	)
#else
mexFunction(nlhs, plhs, nrhs, prhs)
int nlhs, nrhs;
mxArray *plhs[], *prhs[];
#endif
{
	double	*yn, *signal,*XM,*xm;
	double	*ret;
    long int len,q;
    long int tim;
    double lam;
	unsigned int	m,n;
	
	/* Check the dimensions of Y. */

	m = mxGetM(prhs[0]);
	n = mxGetN(prhs[0]);
	if(n<m) tim=m; else tim=n;
	
	/* Create a matrix for the return argument */

	signal = mxGetPr(prhs[0]);

	len = (long int)mxGetScalar(prhs[1]);
	lam = mxGetScalar(prhs[2]);
	if(nrhs==4) XM=mxGetPr(prhs[3]);
	else XM=NFArray(len+1); 

	plhs[0] = mxCreateDoubleMatrix(1, len+1, mxREAL);
	xm = mxGetPr(YP_OUT);
	
	/* Do the actual computations in a subroutine */
	for(q=0;q<len+1;q++)xm[q]=XM[q];
	trans(signal,len,lam,tim,xm);
	return;
}


