function [nodal_phi] = correct_near0_level_sets(nodal_phi)
% If the level set φ(x) of some node is extremely close to 0, then it is set to 0 exactly
% Input:
% nodal_phi = original level sets of nodes of 1 element
% Output:
% nodal_phi = correceted level sets of nodes of 1 element

tol = 1E-8; % tolerance. Anything below it will be set to 0.

min_phi = min(nodal_phi);
max_phi = max(nodal_phi);
diff = max_phi - min_phi;
thres = tol*diff;
for j = 1 : 4 
    if abs(nodal_phi(j)) < thres
        nodal_phi(j) = 0;
    end
end

end