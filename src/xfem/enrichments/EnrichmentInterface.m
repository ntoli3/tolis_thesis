classdef (Abstract) EnrichmentInterface < handle
% Describes an XFEM enrichment function
    methods (Abstract)
        % Evaluates ψ(x) at a point x0.
        % Input:
        % phi = value of level set at the point x0.
        % N = row vector with the shape functions at the point x0.
        % nodal_phi = column vector with the level sets at the nodes of the element containing x0.
        % Output:
        % psi = values of the enrichment function at the point x0.
        [psi] = evaluate(obj, phi, N, nodal_phi);

        % Evaluates the derivatives of ψ(x) at a point x0.
        % Input:
        % phi = value of level set at the point x0.
        % N = row vector with the shape functions at the point x0. 
        % dN_dx = matrix 2x4 containing the derivatives of the shape functions in the cartesian 
        %   system at x0. Row 1 corrsponds to x-derivatives and row 2 to y-derivatives.
        % nodal_phi = column vector with the level sets at the nodes of the element containing x0.
        % Output:
        % grad_psi = 2x1 vector with the gradient of the enrichment function at the point x.
        [grad_psi] = evaluateDerivatives(obj, phi, N, dN_dx, nodal_phi);

        % Returns 1 if nodes of elements tangent to the LSM interface must
        % be enriched, or 0 if they must not.
        % Output:
        % flag = 1 to enrich, 0 to not enrich
        [flag] = mustEnrichTangentNodes(obj);
    end
end