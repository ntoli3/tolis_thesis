function [val, derivatives_cartesian] = Heaviside(phi)
% xwrizei to xwro se duo perioxes
% input:
% phi = h timh ths level set sto gauss point
% output:
% val = h timh ths enrichment function 
% derivatives_cartesian = oi merikes paragwgoi pros x,y

val = sign(phi);
% if phi > 0
%    val = 1; 
% elseif phi < 0
%    val = -1;
% else 
%    val = 0;
% end

derivatives_cartesian = [0; 0];

end

