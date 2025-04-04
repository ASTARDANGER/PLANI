clc; clear; close all;
animation_speed = 500;
% Charger l'image et la convertir en binaire
img = imread('map4.png');
bw = imbinarize(rgb2gray(img)); % Convertir en binaire si nécessaire

% Extraire le contour des obstacles
obstacle_perim = bwperim(bw);

% Dilater les obstacles pour tenir compte du rayon du robot
r = 20; % Rayon du robot en pixels
se = strel('disk', r);
dilated_obstacles = imdilate(obstacle_perim, se);

% Affichage de l'image et sélection des points
figure;
a = 0.6; % foreground opacity
C = a*bw + (1-a)*~dilated_obstacles;
imshow(C);
hold on;

title("Cliquez pour choisir le point de départ et d'arrivée");
[x, y] = ginput(2);
start_point = round([x(1), y(1)]);
goal_point = round([x(2), y(2)]);

% Dessiner les points de départ et d'arrivée
plot(start_point(1), start_point(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
plot(goal_point(1), goal_point(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);

%brasenham
P = bresenham(start_point(1),start_point(2),goal_point(1), goal_point(2));
plot(P(:,1), P(:,2));


% Implémentation de Bug1
current_pos = start_point;
path = current_pos;

theta = linspace(0, 2*pi, 20);
circle_x = r * cos(theta);
circle_y = r * sin(theta);
robot_plot = fill(current_pos(1)+circle_x, current_pos(2)+circle_y, 'b', 'EdgeColor', 'k');

j = 1;
while norm(current_pos - goal_point) > 1
    % Étape 1: Aller en ligne droite jusqu'à l'arrivé
    next_pos = [P(j,1),P(j,2)];
    
    if dilated_obstacles(next_pos(2), next_pos(1))== 1
        
        
        % Étape 2: Enregistrer le point de collision q_Hi
        q_Hi = current_pos;
        plot(q_Hi(1), q_Hi(2), 'go', 'MarkerSize', 7, 'lineWidth', 2);
        % Étape 3: Longer l'obstacle en mémorisant le point le plus proche q_Li
        min_dist = inf;
        q_Li = q_Hi;
        obstacle_path = [];
        start_following = current_pos;
        
        while true
            
      
            % Calculer la distance au but
            dist_to_goal = norm(current_pos - goal_point);
            if dist_to_goal < min_dist
                min_dist = dist_to_goal;
                q_Li = current_pos;
            end
            
            % Trouver le prochain point sur le contour de l'obstacle (exploration horaire)
            neighbors = getNeighbors(current_pos(1), current_pos(2));
            found_next = false;
            for i = 1:8
            % Calculer les indices des pixels dans le sens horaire
            % Les directions horaires commencent par le pixel haut-gauche
            idx = mod(i-1, 8) + 1;
            x = neighbors(idx, 1);
            y = neighbors(idx, 2);
            
            if dilated_obstacles(y, x)==1 % Pixel faux
                i_true = i;
                % Chercher un pixel "vrai" dans le sens anti-horaire
                found_next = true;
                break;
            end
            end
            
            % Si un pixel faux est trouvé, chercher dans le sens anti-horaire
            if found_next
             
                % Chercher un pixel vrai dans le sens anti-horaire
                for i =  i_true : -1 : i_true - 8
                    idx = mod(i - 1, 8) + 1;
                    x = neighbors(idx, 1);
                    y = neighbors(idx, 2);
                    
                    if dilated_obstacles(y, x)==0  % Pixel vrai trouvé
                        next_pos = [x,y];
                        break;
                    end
                end
            
            end

    
            % Ajouter la position actuelle au chemin
            obstacle_path = [obstacle_path; next_pos];

            %On met à jour current_pos
            current_pos = next_pos;
            % Affichage du robot
            plot(next_pos(1), next_pos(2), 'b.', 'MarkerSize', 5);
            set(robot_plot, 'XData', next_pos(1) + circle_x, 'YData', next_pos(2) + circle_y);
            if animation_speed > 0
                pause(1/animation_speed);
            end
            % Vérifier si on a fait un tour complet
            
            [isInList, index] = ismember(next_pos, P, "rows");
            if isInList
                j = index;
                plot(P(j,1), P(j,2), 'ro', 'MarkerSize', 7, 'lineWidth', 2);
                disp(j)
                break;
                
            end
            
        end
     
        % Étape 4: recommencer à parcourir
        path = [path; obstacle_path];
        
        
        
    else
        % Avancer en ligne droite
        current_pos = next_pos;
        path = [path; current_pos];
    end
    
    % Tracé du chemin et du robot
    plot(current_pos(1), current_pos(2), 'b.', 'MarkerSize', 5);
    set(robot_plot, 'XData', next_pos(1) + circle_x, 'YData', next_pos(2) + circle_y);
    if animation_speed > 0
        pause(1/animation_speed);
    end
    j = j+1;
end

% Fin
disp('Trajet terminé !');
path_length = sum(sqrt(diff(path(:,1)).^2 + diff(path(:,2)).^2));
disp(['Longueur du chemin : ', num2str(path_length)]);
