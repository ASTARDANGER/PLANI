% Fonction pour obtenir les coordonnées des 9 pixels autour du pixel central
function coords = getNeighbors(x, y)
    % Définir les directions relatives des 9 pixels (centré, autour)
    directions = [
        -1, -1; % Haut-gauche
         0, -1; % Haut
         1, -1; % Haut-droite
         1,  0; % Droite
         1,  1; % Bas-droite
         0,  1; % Bas
        -1,  1; % Bas-gauche
        -1,  0; % Gauche
         0,  0; % Centre (le pixel de départ)
    ];
    
    % Initialisation de la matrice des coordonnées
    coords = zeros(9, 2); % 9 pixels autour (centre + 8 voisins)
    
    for i = 1:9
        coords(i, :) = [x + directions(i, 1), y + directions(i, 2)];
    end
end