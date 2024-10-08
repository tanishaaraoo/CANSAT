clc;
clear all;
close all;
% Given values
total_impulse = 2533.06;  % NS
propellant_mass = 2.33;    % kg
burn_time = 3.21;         % s
specific_impulse = 111.07; % s
total_mass = 13.36;        % kg (wet mass, including propellant)
dry_mass = total_mass - propellant_mass;  % kg (mass after propellant is burned)
launch_angle_deg = 85;    % degrees
g = 9.81;                 % m/s^2, acceleration due to gravity
drag_coefficient = 0.36;  % Drag coefficient
diameter = 0.182;         % Reference area diameter in meters
rho = 1.225;              % Air density in kg/m^3 at sea level
time_step = 0.01;         % Time step for numerical integration

% Calculating reference area
reference_area = pi * (diameter / 2)^2;  % Reference area in m^2

% Convert launch angle to radians
launch_angle_rad = deg2rad(launch_angle_deg);

% Initial conditions
velocity_y = 0;         % Initial vertical velocity in m/s
position_y = 0;         % Initial vertical position in meters
time = 0;               % Start time
mass = total_mass;      % Initial mass (including propellant)
thrust_phase = true;    % Indicator for thrust phase

% Calculate propellant burn rate (kg/s)
propellant_burn_rate = propellant_mass / burn_time;

% Arrays to store data for plotting/analysis
time_list = [];
velocity_y_list = [];
position_y_list = [];
mass_list = [];

% Numerical integration loop
while thrust_phase || velocity_y > 0
    % Calculate thrust if in thrust phase
    if time <= burn_time
        thrust = total_impulse / burn_time;
        
        % Update mass due to propellant burn
        mass = total_mass - propellant_burn_rate * time;
        if mass < dry_mass
            mass = dry_mass;  % Ensure mass doesn't drop below dry mass
        end
    else
        thrust = 0;
        thrust_phase = false;
    end

    % Calculate drag force
    drag_force = 0.5 * drag_coefficient * rho * reference_area * velocity_y^2;
    if velocity_y > 0
        drag_force = -drag_force;  % Drag opposes the motion
    end

    % Net force in the vertical direction
    net_force_y = thrust * sin(launch_angle_rad) + drag_force - mass * g;

    % Acceleration in vertical direction
    acceleration_y = net_force_y / mass;

    % Update velocity and position
    velocity_y = velocity_y + acceleration_y * time_step;
    position_y = position_y + velocity_y * time_step;

    % Append data to lists
    time_list(end+1) = time;
    velocity_y_list(end+1) = velocity_y;
    position_y_list(end+1) = position_y;
    mass_list(end+1) = mass;

    % Update time
    time = time + time_step;
end

% Peak altitude
peak_altitude_with_drag = max(position_y_list);

% Display the peak altitude
fprintf('Peak Altitude with Drag: %.2f meters\n', peak_altitude_with_drag);

% Plotting Altitude vs Time
figure;
subplot(3,1,1);
plot(time_list, position_y_list, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Altitude (m)');
title('Altitude vs Time');
grid on;

% Plotting Velocity vs Time
subplot(3,1,2);
plot(time_list, velocity_y_list, 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Vertical Velocity (m/s)');
title('Velocity vs Time');
grid on;

% Plotting Mass vs Time
subplot(3,1,3);
plot(time_list, mass_list, 'g', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Mass (kg)');
title('Mass vs Time');
grid on;
