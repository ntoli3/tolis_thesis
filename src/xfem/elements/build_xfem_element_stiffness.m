function [ke] = build_xfem_element_stiffness(xfem_model, element_id)
% Builds the stiffness matrix of an element
% Input:
% xfem_model = object of XfemModel
% element_id = the ID of the target element
% Output:
% ke = the stiffness matrix of the target element

nodal_coords = xfem_model.extractElementCoordinates(element_id);
            
if xfem_model.elements_category(element_id) == 0 % Standard element
    if xfem_model.intersected_elements(element_id) > 0
        material = xfem_model.material_pos;
    else
        material = xfem_model.material_neg;
    end
    ke = quad4_stiffness(nodal_coords, material.E, material.v, material.thickness);

else 
    num_quad_gp = xfem_model.num_quad_points;
    num_triangle_gp = xfem_model.num_subtriangle_points;
    if xfem_model.elements_category(element_id) == 1 % Intersected element
        gauss_points = integration_with_subtriangles(...
            element_id, xfem_model.intersection_mesh, num_triangle_gp);
    else % Blending element
        gauss_points = gauss_integration_quad4(num_quad_gp(1), num_quad_gp(2));
    end
    
    nodal_phi = xfem_model.extractElementLevelSets(element_id);
    nodal_categories = xfem_model.extractElementNodalCategories(element_id);
    ke = xquad4_stiffness(nodal_coords, nodal_categories, nodal_phi, xfem_model.psi_func, ...
        xfem_model.material_pos, xfem_model.material_neg, gauss_points);   
    
    if xfem_model.cohesive_interface == 1 % Must also take the stiffness of the cohesive segments
        interaction_type = abs(xfem_model.intersected_elements(element_id));
        if interaction_type == 1
            % Element does not interact with the cohesive interface. 
            % No cohesive stiffness.
            return; 
        elseif interaction_type == 0
            % Element is intersected by the cohesive interface.
            % Take the full cohesive stiffness
            coeff = 1.0; 
        elseif interaction_type == 2
            % The cohesive interface goes through an element edge.
            % Take half of the cohesive stiffness. A neighbor
            % element will take the other half.
            coeff = 0.5;
        end

        gauss_points_interface = integration_on_interface_segments(...
            element_id, xfem_model.intersection_segments, xfem_model.num_interface_segment_points);
        t = xfem_model.material_pos.thickness;
        k_coh = xquad4_stiffness_cohesive(nodal_coords, nodal_categories, xfem_model.psi_func, ...
            xfem_model.Dcoh, t, gauss_points_interface);
        ke = ke + coeff * k_coh;
    end
    
end


end