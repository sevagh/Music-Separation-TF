#include <stdio.h>
#include <math.h>
#include "mex.h"

double  *NFArray(int size)
{
	double	*p;
	p = (double *)mxCalloc(sizeof(*p),size);
	return p;
}
/**************************************************************/
/* 
/* Alpha -> Sigma mapping                                     */
/*                                                            */
/*	By Aki Härmä  7. 8 1997	                              */
/**************************************************************/ 
void alphas2sigmas(double *alp, double *sigm, double lam, int dim)
{
int q;
double S,Sp;

sigm[dim]=lam*alp[dim]/alp[0];
Sp=alp[dim]/alp[0];
for(q=dim;q>1;q--)
  {
    S=alp[q-1]/alp[0]-lam*Sp;
    sigm[q-1]=lam*S+Sp;
    Sp=S;
  }
sigm[0]=S;
sigm[dim+1]=1-lam*S;

return;
}

/***********************************************************************/
/*  WFILTER.c                                                          */
/* Implementation of a warped FIR/IIR filter using a modification of   */
/* the block diagram. Valid only for real valued coefficients and      */
/* signals.                                                            */
/* */
/* USAGE: [y,z]=wfilter(A,B,x,lam,z]                                   */
/* where y is the output of the filter, z is a vector of inner states  */
/* of the filter, A and B are the coefficients of the filter and lam   */
/* is the warping parameter */
/*                                                                     */
/* Aki Härmä and Matti Karjalainen, Helsinki University of Technology, */
/* Laboratory of Acoustics and Audio Signal Processing                 */
/* This file is a part of the Warping toolbox available at             */
/* http://www.acoustics.hut.fi/software/warp/                          */
/***********************************************************************/
void trans_real(double *ynr, double *rsignal, long int len,
	   double *Ar, int adim, double *Br, int bdim, double lam,
	   double *rmem)
{
 
   int q, w, e, mlen;
   long int o;
  double xr, x, ffr, tmpr, Bb;
  double *sigma;

  sigma=NFArray(bdim+2);
  
  alphas2sigmas(Br,sigma,lam,bdim-1); 
  
  if (adim>=bdim)mlen=adim; else mlen=bdim+1;
  Bb=1/Br[0];
   
       for(o=0;o<len;o++)
      { 
       xr=rsignal[o]*Bb;
          
       /* update feedbackward sum*/
       for(q=0; q<bdim; q++) {xr-=sigma[q]*rmem[q];}

       xr=xr/sigma[bdim]; 

       x=xr*Ar[0];
      /* update inner states*/
       for(q=0;q<mlen;q++)
	 {
	   tmpr=rmem[q]+ lam*(rmem[q+1]-xr);	   
	   rmem[q]=xr;
	   xr=tmpr;
	 }  
       /* update feedforward sum*/
       for(q=0, ffr=0.0; q<adim-1; q++) {ffr+=Ar[q+1]*rmem[q+1];}
       
       /* update output*/
       ynr[o]=x+ffr; 
        
      }
return;
}

/************************  MEXFUNCTION *****************************/
void mexFunction(
	int		nlhs,
	mxArray	*plhs[],
	int		nrhs,
	const mxArray    *prhs[]
	)
{
	double *ynr, *rsignal;
	double *Ar,*Br;
	double *rmems;
	double *Rmems;
	double lam;
        int q, n, m, adim, bdim, mlen;
        int isG = 0;
        long int len,mm,nn;
/* GET POINTERS */
	Ar= mxGetPr(prhs[0]);
        m = (int)mxGetM(prhs[0]);
	n = (int)mxGetN(prhs[0]);
	if(n==1)adim=m; else adim=n;
        Br= mxGetPr(prhs[1]);
            	m = (int)mxGetM(prhs[1]);
	n = (int)mxGetN(prhs[1]);
	if(n==1)bdim=m; else bdim=n;
        if(adim>=bdim)mlen=adim; else mlen=bdim;
        rsignal = mxGetPr(prhs[2]);
      	mm = (long int)mxGetM(prhs[2]);
	nn= (long int)mxGetN(prhs[2]);
	if(nn==1)len=mm; else len=nn;

       plhs[0] = mxCreateDoubleMatrix(1, len, mxREAL);
	ynr = mxGetPr(plhs[0]);
       plhs[1]= mxCreateDoubleMatrix(1,mlen+2,mxREAL);
	Rmems=mxGetPr(plhs[1]);

	lam = mxGetScalar(prhs[3]); /* Value of lambda */
       if (nrhs>4){ 
	 rmems=mxGetPr(prhs[4]); 
	 for(q=0;q<mlen+1;q++) {Rmems[q]=rmems[q];}
       }
	trans_real(ynr,rsignal,len,Ar,adim,Br,bdim,lam,Rmems);
	return;
}


