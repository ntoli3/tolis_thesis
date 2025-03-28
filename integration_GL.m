function gpoints=integration_GL(N)
%selida 42/100
a=-1;
b=1;
[x,w]=lgwt(N,a,b);
m=0;
gpoints=zeros(length(x)*length(x),3);
for i=length(x):-1:1
         for j=length(x):-1:1
             m=m+1;
             gpoints(m,1)=x(j);
             gpoints(m,2)=x(i);
             gpoints(m,3)=w(i)*w(j);
         end
end

