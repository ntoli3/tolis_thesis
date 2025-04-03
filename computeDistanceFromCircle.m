function distance = computeDistanceFromCircle(center, radius, node_coords)
    % Υπολογίζει την απόσταση κάθε κόμβου από τον κύκλο
    
    % συντεταγμένες του κέντρου
    x_c = center;
    y_c = center;
    
    % ακτινα κυκλου
    r = radius;

    % οι συντεταγμενες των κομβων
    node_coords = [X(:), Y(:)];

    % Υπολογισμός της απόστασης κάθε κόμβου από το κέντρο του κύκλου
    distance = abs(node_coords - x_c) - r
    
    % Υπολογισμός της απόστασης από τον κύκλο (Θετική έξω, αρνητική μέσα)
    distance = node_distances - radius;
end
