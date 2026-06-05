% ---------------------------------------------------------
% Herramienta de análisis estructural de vigas simplemente apoyadas
% con base de datos externa (archivo .mat) + menú interactivo
% ---------------------------------------------------------

clear; clc; close all;

%% Nombre del archivo de base de datos
dbfile = 'vigasDB.mat';

% Si no existe, inicializar
if ~isfile(dbfile)
    vigas = struct('id',{},'longitud',{},'cargas_puntuales',{},'cargas_distribuidas',{});
    save(dbfile,'vigas');
else
    load(dbfile,'vigas');
end

%% Menú principal
while true
    % Mostrar menú con opciones numeradas
    disp('--- MENÚ PRINCIPAL ---');
    disp('1. Crear nueva simulación');
    disp('2. Analizar simulación guardada');
    disp('3. Borrar simulación');
    disp('4. Salir');
    
    % Solicitar opción
    opcion = input('Seleccione una opción: ');
    
    switch opcion
        case 1
            %% Crear nueva simulación
            L = input('Longitud de la viga [m]: ');
            puntuales = input('Ingrese cargas puntuales como matriz [pos, magnitud]: ');
            distribuidas = input('Ingrese cargas distribuidas como matriz [x1, x2, q]: ');
            
            if isempty(vigas)
                newID = 1;
            else
                newID = vigas(end).id + 1;
            end
            
            nuevo = struct('id',newID,'longitud',L,...
                           'cargas_puntuales',puntuales,...
                           'cargas_distribuidas',distribuidas);
            
            vigas = [vigas nuevo]; %#ok<AGROW>
            save(dbfile,'vigas');
            
            fprintf('\nSimulación guardada con ID %d.\n', newID);
            
        case 2
            %% Analizar simulación guardada
            if isempty(vigas)
                disp('No hay simulaciones guardadas.');
                continue;
            end
            
            disp('--- Simulaciones guardadas ---');
            for i = 1:length(vigas)
                fprintf('ID: %d | Longitud: %.2f m | Puntuales: %s | Distribuidas: %s\n',...
                    vigas(i).id, vigas(i).longitud, mat2str(vigas(i).cargas_puntuales), mat2str(vigas(i).cargas_distribuidas));
            end
            
            id_sel = input('\nIngrese el ID de la simulación que desea analizar: ');
            
            if ~ismember(id_sel,[vigas.id])
                fprintf('El ID ingresado no existe.\n');
                continue;
            end
            
            selData = vigas([vigas.id] == id_sel);
            L = selData.longitud;
            puntuales = selData.cargas_puntuales;
            distribuidas = selData.cargas_distribuidas;
            
            fprintf('\nSimulación seleccionada:\n');
            disp(puntuales);
            disp(distribuidas);
            
            %% Cálculo de reacciones en apoyos
           F_total = 0;
M_A = 0;

% Solo entrar si puntuales no está vacío y tiene al menos 2 columnas
if ~isempty(puntuales) && size(puntuales,2) >= 2
    F_total = F_total + sum(puntuales(:,2));
    for i = 1:size(puntuales,1)
        M_A = M_A + puntuales(i,2)*puntuales(i,1);
    end
end

            for i = 1:size(distribuidas,1)
                q = distribuidas(i,3);
                a = distribuidas(i,1); b = distribuidas(i,2);
                F_total = F_total + q*(b-a);
                Fd = q*(b-a);
                x_eq = a + (b-a)/2;
                M_A = M_A + Fd*x_eq;
            end
            
            RB = M_A/L;
            RA = -F_total - RB;
            
            fprintf('\nReacción en A: %.2f N\n', RA);
            fprintf('Reacción en B: %.2f N\n', RB);
            
            %% Diagramas
            x = linspace(0,L,500);
            V = zeros(size(x));
            M = zeros(size(x));
            
            for i = 1:length(x)
                xi = x(i);
                V(i) = RA;
                for j = 1:size(puntuales,1)
                    if xi >= puntuales(j,1)
                        V(i) = V(i) + puntuales(j,2);
                    end
                end
                for j = 1:size(distribuidas,1)
                    a = distribuidas(j,1); b = distribuidas(j,2); q = distribuidas(j,3);
                    if xi >= a
                        if xi <= b
                            V(i) = V(i) + q*(xi-a);
                        else
                            V(i) = V(i) + q*(b-a);
                        end
                    end
                end
                
                M(i) = RA*xi;
                for j = 1:size(puntuales,1)
                    if xi >= puntuales(j,1)
                        M(i) = M(i) + puntuales(j,2)*(xi-puntuales(j,1));
                    end
                end
                for j = 1:size(distribuidas,1)
                    a = distribuidas(j,1); b = distribuidas(j,2); q = distribuidas(j,3);
                    if xi >= a
                        if xi <= b
                            M(i) = M(i) + q*(xi-a)*(xi-a)/2;
                        else
                            M(i) = M(i) + q*(b-a)*(xi-(a+(b-a)/2));
                        end
                    end
                end
            end
            
            figure;
            subplot(2,1,1);
            plot(x,V,'b','LineWidth',2); grid on;
            xlabel('Longitud [m]'); ylabel('Cortante V(x) [N]');
            title('Diagrama de Fuerza Cortante');
            
            subplot(2,1,2);
            plot(x,M,'r','LineWidth',2); grid on;
            xlabel('Longitud [m]'); ylabel('Momento M(x) [N·m]');
            title('Diagrama de Momento Flector');
            
        case 3
           %% Borrar simulación
if isempty(vigas)
    disp('No hay simulaciones guardadas.');
    continue;
end

disp('--- Simulaciones guardadas ---');
for i = 1:length(vigas)
    fprintf('ID: %d | Longitud: %.2f m | Puntuales: %s | Distribuidas: %s\n',...
        vigas(i).id, vigas(i).longitud, mat2str(vigas(i).cargas_puntuales), mat2str(vigas(i).cargas_distribuidas));
end

id_del = input('\nIngrese el ID de la simulación que desea borrar: ');

if ~ismember(id_del,[vigas.id])
    fprintf('El ID ingresado no existe.\n');
    continue;
end

% Eliminar la simulación
vigas([vigas.id] == id_del) = [];

% Reasignar IDs consecutivos
for i = 1:length(vigas)
    vigas(i).id = i;
end

% Guardar cambios
save(dbfile,'vigas');

fprintf('\nSimulación eliminada. Los IDs han sido renumerados.\n');

% Mostrar simulaciones restantes
disp('--- Simulaciones restantes ---');
for i = 1:length(vigas)
    fprintf('ID: %d | Longitud: %.2f m | Puntuales: %s | Distribuidas: %s\n',...
        vigas(i).id, vigas(i).longitud, mat2str(vigas(i).cargas_puntuales), mat2str(vigas(i).cargas_distribuidas));
end

        case 4
            disp('Saliendo del programa...');
            break;
            
        otherwise
            disp('Opción inválida, intente de nuevo.');
    end
end
