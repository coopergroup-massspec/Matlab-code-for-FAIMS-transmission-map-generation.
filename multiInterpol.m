
function  [vq]=multiInterpol(Ydata,Xdata,xq)
[R,C]=size(Ydata);
vq=zeros(R,length(xq));
    for j=1:R
         v=1;
        for k=1:length(xq)
            True=0;
            while True == 0

            if Xdata(j,v)<=xq(k) && xq(k)<Xdata(j,(v+1)) 
                    x1=Xdata(j,v);
                    x2=Xdata(j,(v+1));
                    y1=Ydata(j,v);
                    y2=Ydata(j,(v+1));

                    m=(y2-y1)/(x2-x1);
                    c=y1-m*x1;

                    vq(j,k)=(m*xq(k))+c;
                    
                    True=1;

            else
                 
                v=v+1;
                          
            end
            end
         end
    end
end
