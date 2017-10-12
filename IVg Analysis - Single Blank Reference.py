#Defines the function for the analysis.

def calculate(filepath):
    import sys
    from numpy import NaN, Inf, arange, isscalar, asarray, array
    
    import numpy as np
    import matplotlib.pyplot as plt
    #load txt file into 3 groups
    x, none, y  = np.loadtxt(filepath, skiprows=2, unpack=True)

    #Defines the peak determining function.
    
    def peakdet(v, delta, x = None):
        """
        Converted from MATLAB script at http://billauer.co.il/peakdet.html
        
        Returns two arrays
        
        function [maxtab, mintab]=peakdet(v, delta, x)
        %PEAKDET Detect peaks in a vector
        %        [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
        %        maxima and minima ("peaks") in the vector V.
        %        MAXTAB and MINTAB consists of two columns. Column 1
        %        contains indices in V, and column 2 the found values.
        %      
        %        With [MAXTAB, MINTAB] = PEAKDET(V, DELTA, X) the indices
        %        in MAXTAB and MINTAB are replaced with the corresponding
        %        X-values.
        %
        %        A point is considered a maximum peak if it has the maximal
        %        value, and was preceded (to the left) by a value lower by
        %        DELTA.
        
        % Eli Billauer, 3.4.05 (Explicitly not copyrighted).
        % This function is released to the public domain; Any use is allowed.
        
        """
        maxtab = []
        mintab = []
        maxp = []
        minp = []
           
        if x is None:
            x = arange(len(v))
        
        v = asarray(v)
        
        if len(v) != len(x):
            sys.exit('Input vectors v and x must have same length')
        
        if not isscalar(delta):
            sys.exit('Input argument delta must be a scalar')
        
        if delta <= 0:
            sys.exit('Input argument delta must be positive')
        
        mn, mx = Inf, -Inf
        mnpos, mxpos = NaN, NaN
        
        lookformax = True
        
        for i in arange(len(v)):
            this = v[i]
            if this > mx:
                mx = this
                mxpos = x[i]
            if this < mn:
                mn = this
                mnpos = x[i]
            
            if lookformax:
                if this < mx-delta:
                    maxtab.append(mx)
                    maxp.append(mxpos)
                    mn = this
                    mnpos = x[i]
                    lookformax = False
            else:
                if this > mn+delta:
                    mintab.append(mn)
                    minp.append(mnpos)
                    mx = this
                    mxpos = x[i]
                    lookformax = True

        return maxtab, maxp, mintab, minp



    #Define smoothing function (Savitzky Golay)
    
    def savitzky_golay(y, window_size, order, deriv=0, rate=1):

        import numpy as np
        from math import factorial

        try:
            window_size = np.abs(np.int(window_size))
            order = np.abs(np.int(order))
        except ValueError, msg:
            raise ValueError("window_size and order have to be of type int")
        if window_size % 2 != 1 or window_size < 1:
            raise TypeError("window_size size must be a positive odd number")
        if window_size < order + 2:
            raise TypeError("window_size is too small for the polynomials order")
        order_range = range(order+1)
        half_window = (window_size -1) // 2
        # precompute coefficients
        b = np.mat([[k**i for i in order_range] for k in range(-half_window, half_window+1)])
        m = np.linalg.pinv(b).A[deriv] * rate**deriv * factorial(deriv)
        # pad the signal at the extremes with
        # values taken from the signal itself
        firstvals = y[0] - np.abs( y[1:half_window+1][::-1] - y[0] )
        lastvals = y[-1] + np.abs(y[-half_window-1:-1][::-1] - y[-1])
        y = np.concatenate((firstvals, y, lastvals))
        return np.convolve( m[::-1], y, mode='valid')

    #transfer x,y into list
    yl=[]
    xl=[]
    for i in range (0,len(y)):
        yl.append(y[i])
    for j in range (0,len(x)):
        xl.append(x[j])

    interval=(xl[0]-xl[199])/200 

    #get 1st derivative with smooth once
    y1st= savitzky_golay(y, 35, 2)
    der=-np.gradient(y1st,interval)

    lder=[]  
    rx=[]
    #limit der, xl within the range of not being affected by smoothing,x not being effected by smoothing
    for i in range (25, len(xl)):
        rx.append(xl[i])
    for i in range (0,len(der)):
        lder.append(der[i])

    [maxtab, maxp, mintab, minp] = peakdet(y, 0.00000001, x)
    
    if len(mintab)==0:
        gmin=min(yl)
        gminx=xl[yl.index(gmin)]
        
    else:
        gmin=min(mintab)   #here gmin refers to current, not conductance
        gminx=minp[mintab.index(gmin)]
 
    gminindex=xl.index(gminx)

    slimitlder=[]
    for i in range (gminindex, 183):
        slimitlder.append(lder[i]) 
    #Get the sharpest point of slope   
    slope=min(slimitlder)
    indexslope=lder.index(slope)
                      
    #Change the values in the abs function to select the current at a desired Vg. 
    #Example: i3 = y[np.argmin(abs(x-10.0))] selects current at 10 Vg. 
    
    i3 = y[np.argmin(abs(x-0.4))]
    in3= y[np.argmin(abs(x+0.4))]
    
    i4= y[np.argmin(abs(x-0.8))]
    in4= y[np.argmin(abs(x+0.8))]
    
    i6= y[np.argmin(abs(x-0.0))]
    in6= y[np.argmin(abs(x+0.0))]

    #Get the right most of the linear region
    from scipy import stats
    import numpy as np
    for i in range (3,indexslope-gminindex):
        slope, intercept, r_value, p_value, std_err = stats.linregress(x[indexslope-i:indexslope], y1st[indexslope-i:indexslope])
        if r_value**2 < 0.9999:
           break
           end
    linearightmost=indexslope-i
    for i in range (linearightmost+3,183):
        slope, intercept, r_value, p_value, std_err = stats.linregress(x[linearightmost:i], y1st[linearightmost:i])     #make a change here 08/09,not slope but sslope, since slope will replace the slope value we used before
        if r_value**2 < 0.9995:
           break
           end
        
    #get the x intercept
    xintercept= -intercept/slope
    yintercept=intercept
    
    xvth= (gmin-yintercept)/slope  
    vth=xl[np.argmin(abs(x-xvth))]
    
    #All 10 parameters are returned.
    #Y-intercept, transconductance, threshold voltage, current at specified Vg, minimum conductance
    
    return yintercept, slope, vth, i6, in6, i4, in4, i3, in3, gmin/0.05

#Start of the analysis code.

import glob, os

ssample=[]

#Set the directory to the location of the IVg text files. Use forward slash!!!

for file in glob.glob("C:/Users/Sean/Box Sync/Graduate School/Research/Data/Sensor/Source Meter/THC Sensor/2017-01-17 - THC 27-28 P3 - THC and EtOH test/THC 28 Device D - Sensing IVg Neg*"):
    
    ssample.append(file)
            
#Calculates the variables for the reference

[yintercept, slope, vth, i6, in6, i4, in4, i3, in3, gmin] = calculate(ssample[0])

#Prints the calculated variables for the samples of each measurement

for i in range (0,len(ssample)):
    
    [syintercept, sslope, svth, si6, sin6, si4, sin4, si3, sin3, sgmin] = calculate(ssample[i])
    
    p1=sslope                       #Transconductance
    p2=svth                         #Threshold voltage
    p3=si3                          #Current at specified Vg
    p4=sin3                         #Current at specified Vg
    p5=si4                          #Current at specified Vg
    p6=sin4                         #Current at specified Vg
    p7=si6                          #Current at specified Vg
    
    print p1, "\t", p2, "\t", p3, "\t", p4, "\t", p5, "\t", p6, "\t", p7, "\t", ssample[i]
    
# 'The Star research group @PITT reserves all the rights'
