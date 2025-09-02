clc
clear al

filename = 'M1_1stVid_t199c1-3.tif';
tif_image = imread(filename); %RGB, R = (:,:,1), G = (:, :, 2), B = (:,:,3)

NP_image_path = tif_image(:,:,2);
pathway_probe_path = tif_image(:,:,3); 

mask_image = NP_image_path;

[mask,x,y,NP_channel_mask] = roipoly_multi(mask_image);

pathway_probe_channel = pathway_probe_path;

pathway_probe_threshold = mask_image * 0;
pathway_probe_threshold(pathway_probe_channel > 36 ) = 1; %2nd channel signal thresholding in pixel value

%calculates colocalization score
c_score = sum(pathway_probe_threshold(mask{1} == 1))./sum(mask{1} == 1, 'all');

%saving threshold figures to show what the nanoparticle mask overlaps
f1 = figure('visible','off');
imagesc(NP_channel_mask)
f2 = figure('visible','off');
imagesc(pathway_probe_threshold)
f3 = figure('visible','off');
imagesc(labeloverlay(NP_channel_mask, pathway_probe_threshold));

saveas(f1, strcat(erase(filename,'.tif'),' AuNP mask.png'));
saveas(f2, strcat(erase(filename,'.tif'),' Dextran Threshold.png'));
saveas(f3, strcat(erase(filename,'.tif'),' Overlaid AuNP mask on thresholded dextran signal.png'));
%figure()
%imagesc(pathway_probe_channel)
%figure()
%imagesc(pathway_probe_threshold)