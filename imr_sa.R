IMRChart<-function(x,xname,xLab=NULL,xLabName,bMed,bSD,bT1,bT2,bT3,bT4,bT5,bT6,bT7,bT8,pTs=NULL){
    library(calibrate)
    x<-unlist(x)
    sframe<-data.frame(xname=x)
    names(sframe)<-c(xname)
	bTests<-c(bT1,bT2,bT3,bT4,bT5,bT6,bT7,bT8)
	
	# TEST VALUES 
	if(length(pTs)==0)
	{
		t2s<-2
		t3s<-4
		t4s<-6
		t5s<-9
		t6s<-8
		t7s<-14
		t8s<-15
	}
	else
	{
		t2s<-as.numeric(pTs[1])
		t3s<-as.numeric(pTs[2])
		t4s<-as.numeric(pTs[3])
		t5s<-as.numeric(pTs[4])
		t6s<-as.numeric(pTs[5])
		t7s<-as.numeric(pTs[6])
		t8s<-as.numeric(pTs[7])
	}
	
    # PARAMETERS
     x.dim<-length(x)
    
    #X DATA
     x.ave <- ave(x)
     sframe$xave<-x.ave
    
    #MOVING RANGE    
     x.mr<-vector()
     x.mr[1]<-NA	
     for(i in 2:x.dim)
     {
         x.mr[i]<-abs(x[i]-x[i-1])
     }
     x.avemr<-ave(x.mr[2:x.dim])
     x.avemr<-c(x.avemr,x.avemr[1])

     x.medmr<-rep(median(x.mr[2:x.dim]),x.dim)
    # x.medmr<-c(x.medmr,x.medmr[1])  

     sframe$mr<-x.mr
	 sframe$mrave<-x.avemr	
	 sframe$mrmed<-x.medmr
    #CONTROL LIMITS
	
	#MEAN / MEDIAN SWITCH
	if(bMed)
	{
     sframe$UCLx<-x.ave+3.145*x.medmr[1]
     sframe$LCLx<-x.ave-3.145*x.medmr[1]
     sframe$UCLr<-x.medmr*3.865	 
	}
	else
	{
	 sframe$UCLx<-x.ave+2.66*x.avemr[1]    
	 sframe$LCLx<-x.ave-2.66*x.avemr[1]
	 sframe$UCLr<-x.avemr*3.268
	}


     sframe$LCLr<-rep(0,x.dim)
    
    # SD LINES   
    sframe$SDP2<-x.ave+2*(sframe$UCLx-x.ave)/3
	sframe$SDP1<-x.ave+(sframe$UCLx-x.ave)/3
	sframe$SDN1<-x.ave-(x.ave-sframe$LCLx)/3	
	sframe$SDN2<-x.ave-2*(x.ave-sframe$LCLx)/3	

    #LABELS
    labelsx<-rep("",x.dim)    
    labelsr<-rep("",x.dim)

    ###########  X DATA ###########
	
	#TEST 8 15 PTS IN A ROW WITHIN 1 SD
	if(bTests[8] && x.dim > t8s)
	{
		for(i in t8s:length(x))
		{
			if(all(x[(i-(t8s-1)):i] < (sframe$SDP1[1])) && all(x[(i-(t8s-1)):i] > (sframe$SDN1[1])))
			{
				labelsx[i] <- "8"
			}
		}
	}	
	
	#TEST 7 14 PTS IN A ROW ALT UP/DOWN
	if(bTests[7]&& x.dim > t7s)
	{
		pattern = rep(1,(t7s-1))
		pattern[2*(1:((t7s-2)/2))] = -1
			
			
		
		#pattern<-c(1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1)

		for(i in t7s:length(x))
		{	
			bPlot7 = TRUE
			bHasNAN = TRUE
			


			test7<-(diff(x[(i-(t7s-1)):i]))/(abs(diff(x[(i-(t7s-1)):i])))
			bHasNAN<- TRUE %in% is.nan(test7)

	
			if(!bHasNAN && bPlot7)
			{
				if(all(test7 == pattern) || all(test7 == -pattern))
				{
					labelsx[i] <- "7"
				}
			}
		}
	}
	
	#TEST 6 8 PTS IN A ROW BEYOND 1 SD
	if(bTests[6]&& x.dim > t6s)
	{
		for(i in t6s:length(x))
		{
			if(all(x[(i-(t6s-1)):i] > (sframe$SDP1[1])) || all(x[(i-(t6s-1)):i] < (sframe$SDN1[1])))
			{
				labelsx[i] <- "6"
			}
		}
	}	
	
	# TEST 5 9 PTS IN A ROW, EITHER SIDE OF CENTER LINE
	if(bTests[5]&& x.dim > t5s)
	{
		for(i in t5s:x.dim)
		{
			if(all(x[(i-(t5s-1)):i] > x.ave[1]) || all(x[(i-(t5s-1)):i] < x.ave[1]))
			{
				labelsx[i] <- "5"
			}
		
		}
	}

    # TEST 4 6 PTS IN A ROW, DECREASING OR INCREASING
	if(bTests[4]&& x.dim > t4s)
	{
		for(i in t4s:x.dim)
		{
			if(all(x[(i-(t4s-1)):i] == sort(x[(i-(t4s-1)):i])) || all(x[(i-(t4s-1)):i] == sort(x[(i-(t4s-1)):i], decreasing = T)))
			{
				labelsx[i] <- "4"
			}
		}
	}	
	
	#Test 3 - 4 OUT OF 5 PTS OUTSIDE +/- 1 SD
	if(bTests[3]&& x.dim > t3s + 1)
	{
		for(i in (t3s+1):length(x))
		{
			varL = (x[(i-t3s):i] < (sframe$SDN1[1]))
			varG = (x[(i-t3s):i] > (sframe$SDP1[1]))
			
			if(length(varL[varL==TRUE]) > t3s-1 || length(varG[varG==TRUE]) > t3s-1)
			{
				labelsx[i]<-"3"
			}
		}
	}

	#Test 2 - 2 OUT OF 3 PTS OUTSIDE +/- 2 SD
	if(bTests[2]&& x.dim > t2s+1)
	{
		for(i in (t2s+1):length(x))
		{
			varL = (x[(i-t2s):i] < (sframe$SDN2[1]))
			varG = (x[(i-t2s):i] > (sframe$SDP2[1]))
			
			if(length(varL[varL==TRUE]) > t2s-1 || length(varG[varG==TRUE]) > t2s-1)
			{
				labelsx[i]<-"2"
			}
		}
	}	
	
	
    # TEST 1 OUTSIDE CONTROL LIMITS 'X'
    if(bTests[1])
	{
		for(i in 1:x.dim)
		{

		   if(x[i] > sframe$UCLx[1])    
			{
				labelsx[i]<-"1"
			}
			
			if(x[i] < sframe$LCLx[1])    
			{
				labelsx[i]<-"1"
			}
		}
    }
    ######### MOVING RANGE #########
    
    # TEST 1 OUTSIDE CONTROL LIMITS 'R'
    if(bTests[1])
	{
		for(i in 2:x.dim)
		{
			if(x.mr[i] > sframe$UCLr[1])    
			{
				labelsr[i]<-"1"
			}

		}
    }
    
    #LABELS INTO THE RESULT
    
    sframe$labelsx<-labelsx
    sframe$labelsr<-labelsr
    
    
#return(sframe)
    xend<-length(sframe[,1])
	
	#Labels
	chartTitle = "Individuals Chart"
	yaxisTitle = xname
	
	#x axes
	if(length(xLab==0))
	{
		xlabels<-seq(1:xend)
	}
	else
	{
		xlabels<-xLab
	}
	
	sXlab = xLabName
	
	# PLOT CANVAS, 2 HIGH x 1 WIDE 
	par(mfrow=c(2,1))
	
	# AXIS LIMITS FOR I-CHART
	xmax<-ceiling(max(sframe[,6],sframe[,1]))
    xmin<-floor(min(sframe[,7],sframe[,1]))
		
	# EMPTY CHART (TYPE="n")
	plot(sframe[,1],type="n",ylab=yaxisTitle,ylim=c(xmin,xmax),xaxt="n",xlab=sXlab,main=chartTitle)
	axis(1,at=1:xend,labels=xlabels)
	
	# INDIVIDUALS
	lines(seq(1:xend),sframe[,1],type="l")
	
	# AVERAGE LINE
	lines(seq(1:xend),sframe$xave,type="l")
	
	# LOWER CONTROL LIMIT
	lines(seq(1:xend),sframe$LCLx,type="l",col="red")
	
	# UPPER CONTROL LIMIT
	lines(seq(1:xend),sframe$UCLx,type="l",col="red")	

	# SHOW STANDARD DEVIATION LINES IF SELECTED
	if(bSD)
	{
	lines(seq(1:xend),sframe$SDP2,type="l",col="gray")	
	lines(seq(1:xend),sframe$SDP1,type="l",col="gray")	
	lines(seq(1:xend),sframe$SDN1,type="l",col="gray")	
	lines(seq(1:xend),sframe$SDN2,type="l",col="gray")		
	}
	

	# ADD LABELS FOR TEST VIOLATIONS
	textxy(seq(1:xend),sframe[,1],labs=sframe$labelsx,cex=1.25,pos=4,col="red")
	
	# AXIS LIMITS FOR mR-CHART (MIN = 0 ALWAYS)
	rmax<-ceiling(max(sframe[,8],sframe[,3][2:xend]))
	
	# EMPTY CHART (TYPE="n")
	plot(sframe$mr,type="n",main="Moving Range Chart",ylab="Moving Range",xlab=sXlab,xaxt="n",ylim=c(0,rmax))
	axis(1,at=1:xend,labels=xlabels)
	
	# MOVING RANGE
	lines(seq(1:xend),sframe$mr,type="l")
	
	# UPPER CONTROL LIMIT
	lines(seq(1:xend),sframe$UCLr,type="l",col="red")
	
	# ADD LABELS FOR TEST VIOLATIONS
	textxy(seq(2:xend),sframe$mr[2:xend],labs=sframe$labelsr[2:xend],cex=1.25,pos=4,col="red")
	
    
}
