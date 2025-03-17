function [phi_nodes]=lsm_node_Khoei(x)
X_inter=0;
for i=1:length(x)
    phi_nodes(i)=abs(x(i,1)-X_inter).*sign(1.*(x(i,1)-X_inter));
end