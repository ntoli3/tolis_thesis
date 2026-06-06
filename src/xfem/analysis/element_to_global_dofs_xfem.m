function [global_dofs] = element_to_global_dofs_xfem(...
  element_id, element_nodes, enriched_nodes, dof_order)
% Ypologizei ta katholika DOFS enos peperasmenoy stoixeioy me vasi ta IDS twn komvon twn stoixeiwn
% Input:
% element_id = arithmos ID toy stoixeiou gia to opoio theloyme ta DOFS
% element_nodes = connectivity matrix (num_elements x num_nodes_per_element). Each row contains the global node IDs of one element.
% enriched_nodes = vector (num_nodes x 1) indicating whether each node is enriched. 0 -> standard node. 1 -> enriched node
% dof_order = 
% Output: 
% global_dofs = katholikoi deiktes DOFS gia to stoixeio

% Find enriched nodes of this element
num_nodes_per_element = size(element_nodes, 2);
enriched_nodes_of_element = [];
for n = 1:num_nodes_per_element
    node_id = element_nodes(element_id, n);
    if enriched_nodes(node_id) == 1
        node_id = element_nodes(element_id, n);
        enriched_nodes_of_element = [enriched_nodes_of_element; node_id];
    end
end

% Count dofs
num_enriched_nodes = length(enriched_nodes_of_element);
num_dofs_standard = 2 * num_nodes_per_element;
num_dofs_enriched = 2 * num_enriched_nodes;
num_dofs_element = num_dofs_standard + num_dofs_enriched;
global_dofs = zeros(1, num_dofs_element);

% Standard dofs
d = 0;
for n = 1: num_nodes_per_element
    node_id = element_nodes(element_id, n);
    d = d + 1;
    global_dofs(d) = dof_order(node_id, 1); % ux of node
    d = d + 1;
    global_dofs(d) = dof_order(node_id, 2); % uy of node
end

% Enriched dofs
for n = 1: num_enriched_nodes
    node_id = enriched_nodes_of_element(n);
    d = d + 1;
    global_dofs(d) = dof_order(node_id, 3); % enriched-x of node
    d = d + 1;
    global_dofs(d) = dof_order(node_id, 4); % enriched-y of node
end

end
