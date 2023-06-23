% Custom blue to red colormap with white in the center
% Input argument defines the resolution/number of colors
% Returns 2-D matrix with 3 columns (RGB) and n rows (n = number of colors)
function [map] = hotcold (n_colors)

% Define start/end color values
% For white/gray center, use identical values for r_end, g_end, b_start.
r_start = 0.2;
r_end = 1.0;
g_start = 0.35;
g_end = 1.0;
b_start = 1.0;
b_end = 0.2;

% Use these for full saturation:
% r_start = 0.0;
% r_end = 1.0;
% g_start = 0.0;
% g_end = 1.0;
% b_start = 1.0;
% b_end = 0.0;

% Check if n is odd or even
if (mod(n_colors,2) ~= 0)
    odd = 1;
else
    odd = 0;
end

map = zeros(n_colors,3);

% Difference between start and end values normalized to resolution
n_norm = (n_colors + odd) / 2;
r_diff = (r_end - r_start) / (n_colors - n_norm);
g_diff = (g_end - g_start) / (n_colors - n_norm);
b_diff = (b_end - b_start) / (n_colors - n_norm);

% For color numbers lower than the center, red increases, green increases, blue
% stays high.
% For color numbers higher than the center, red stays high, green decreases, blue
% decreases.
for i = 1:n_colors
    if(i <= n_colors / 2)
        map(i,:) = [(r_start + (i - 1) * r_diff),(g_start + (i - 1) * g_diff),(b_start)];
    else
        map(i,:) = [(r_end),(g_end - (i - n_norm) * g_diff),(b_start + (i - n_norm) * b_diff)];
    end
end

% Uncomment to plot colormap and RGB values!
% figure;
% x = 1:1:n_colors;
% colormap(map);
% imagesc(x);
% figure;
% rgbplot(map);