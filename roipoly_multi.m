function [masks, xi, yi, labeled_masks] = roipoly_multi(imgs, varargin)
%Names
nv_names = {'ref', 'selection', 'xi', 'yi', 'binary', 'binary_value', 'slice', 'num_masks', 'num_vertices', 'show_mask', 'view', 'save', 'filename', 'directory'};

%Default values
nv_arg.selection = 'roipoly';
nv_arg.num_masks = 1;
nv_arg.num_vertices = 5;
nv_arg.xi = zeros(0, 0);
nv_arg.yi = zeros(0, 0);
nv_arg.binary = zeros(0, 0);
nv_arg.binary_value = 1;
nv_arg.threshold = 10/255; %thresholding percentage of total (% of 255)

for i = 1:2:length(varargin)
    if ischar(varargin{i}) && any(strcmp(varargin{i}, nv_names))
        nv_arg.(varargin{i}) = varargin{i+1};
    else
        error('Invalid name value argument. Valid name value arguments are num_masks, num_vertices, xi, yi, binary, binary_value');
    end    
end

ref_img = imgs(:, :, 1);
labeled_masks = zeros(size(imgs, 1), size(imgs, 2)); %Used to label different regions of interest

% Using interactive GUI roipoly() to define regions of interest
masks = cell(nv_arg.num_masks, 1);
xi = zeros(nv_arg.num_masks, nv_arg.num_vertices);
yi = zeros(nv_arg.num_masks, nv_arg.num_vertices);

figure('Color', 'w', 'Position', [100 100 400 400]);
imagesc(ref_img);
axis image;
colormap gray;
if strcmp(nv_arg.selection, 'roipoly') 
    for i = 1:nv_arg.num_masks
        masks{i} = zeros(size(imgs, 1), size(imgs, 2), size(imgs, 3));
        [masks{i}(:, :, 1), xi(i, :), yi(i, :)] = roipoly();
            
        for j = 2:size(imgs, 3)
            masks{i}(:, :, j) = masks{i}(:, :, 1);
        end
        
        masks{i}(imgs(:, :, 1) < 255 * nv_arg.threshold) = 0;
                   
        labeled_masks(masks{i} > 0) = i;
    end
% Using coordinates to define regions of interest    
elseif strcmp(nv_arg.selection, 'coordinates')
    masks = cell(size(nv_arg.xi, 1));
    nv_arg.num_masks = length(masks);
    xi = nv_arg.xi;
    yi = nv_arg.yi;
 
    for i = 1:length(masks)
        masks{i} = zeros(size(imgs, 1), size(imgs, 2), size(imgs, 3));
        masks{i}(:, :, 1) = roipoly(ref_img, xi(i, :), yi(i, :));
        
        for j = 2:size(imgs, 3)
            masks{i}(:, :, j) = masks{i}(:, :, 1);
        end
        
        masks{i}(imgs(:, :, 1) < 255 * nv_arg.threshold) = 0; %applying threshold to mask

        labeled_masks(masks{i} > 0) = i;
    end
end
    
figure('Color', 'w');
imagesc(imgs(:, :, 1));
axis image
hold on

contour_masks = labeled_masks(:, :, 1);
num_contours = max(contour_masks, [], 'all');
temp_cell = cell(num_contours, 1);

for k = 1:num_contours
    temp_mask = contour_masks;
    temp_mask(contour_masks ~= k) = 0;
    temp_cell{k} = bwboundaries(temp_mask);
end
contour_masks = temp_cell;

for k = 1:length(contour_masks)
    for l = 1:length(contour_masks{k})
        outline = contour_masks{k}{l};
        plot(outline(:, 2), outline(:, 1), 'LineWidth', 2);
    end
end
